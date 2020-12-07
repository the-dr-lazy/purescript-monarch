{-|
Module     : Monarch.Document
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Document
  ( Spec
  , Document'
  , document
  , document_
  )
where

import Prelude

import Type.Row              ( type (+) )
import Data.Maybe
import Effect                ( Effect )
import Effect.Ref                                        as Ref
import Web.HTML              ( HTMLElement )
import Monarch.Event         ( Event
                             , Unsubscribe
                             , debounceImmediate
                             , debounceAnimationFrame
                             , subscribe
                             )
import Monarch.Platform      ( Platform
                             , mkPlatform
                             , runPlatform
                             )
import Monarch.Platform                                  as Platform
import Monarch.Queue                                     as Queue
import Monarch.Html          ( Html )
import Monarch.Scheduler
import Monarch.VirtualDom.VirtualDomTree ( VirtualDomTree )
import Monarch.VirtualDom.OutputHandlersList (OutputHandlersList)
import Monarch.VirtualDom.OutputHandlersList as OutputHandlersList
import Monarch.VirtualDom.PatchTree
import Monarch.VirtualDom.NS                             as NS
import Monarch.VirtualDom                                as VirtualDom
import Monarch.Web.Window    ( requestAnimationFrame )
import Monarch.Monad.Maybe   ( whenJustM )

-- | Document's full input specification
type Spec input model message output effects a r
  = Platform.Spec input model message output effects a
  + ( view      :: model -> Html message
    , container :: HTMLElement
    | r
    )

type Document input model message output
  = { platform  :: Platform input model message output
    , sRender   :: Effect Unsubscribe
    , sWorkLoop :: Effect Unsubscribe
    , sCommit   :: Effect Unsubscribe
    }

mkDocument :: forall input model message output effects a r
            . { | Spec input model message output effects a r }
           -> Effect (Document input model message output)
mkDocument spec@{ view, container } = do
  qVNode     <- Queue.new
  qPatchTree <- Queue.new

  platform@{ eModel, dispatchMessage } <- mkPlatform spec

  let
    dispatchPatchTree = qPatchTree.dispatch
    outputHandlers = OutputHandlersList.nil dispatchMessage
    render = qVNode.dispatch <<< view
    commit = VirtualDom.applyPatchTree container

  pure
    { platform
    , sRender: eModel # subscribe render
    , sWorkLoop: workLoop { container
                          , outputHandlers
                          , dispatchPatchTree
                          , eVNode: qVNode.event
                          }
    , sCommit: qPatchTree.event # debounceAnimationFrame
                                # subscribe commit
    }

runDocument :: forall input model message output. Document input model message output -> Effect Unsubscribe
runDocument { sRender, sWorkLoop, sCommit, platform } = do
  -- Subscriptions
  unsubscribeCommit   <- sCommit
  unsubscribeWorkLoop <- sWorkLoop
  unsubscribeRender   <- sRender
  unsubscribePlatform <- runPlatform platform
  -- Unsubscribe
  pure do
    unsubscribePlatform
    unsubscribeRender
    unsubscribeWorkLoop
    unsubscribeCommit

type Document' input output
  = { unsubscribe   :: Effect Unit
    , eOutput       :: Event output
    , dispatchInput :: input -> Effect Unit
    }

document :: forall input model message output effects a r
          . { | Spec input model message output effects a r }
         -> Effect (Document' input output)
document spec = do
  d@{ platform } <- mkDocument spec
  unsubscribe <- runDocument d
  pure { unsubscribe
       , eOutput: platform.eOutput
       , dispatchInput: platform.dispatchInput
       }

document_ :: forall input model message output effects a r
           . { | Spec input model message output effects a r }
          -> Effect Unit
document_ = do
  void <<< document

type WorkLoopSpec slots message
  = { eVNode            :: Event (VirtualDomTree NS.HTML slots message)
    , container         :: HTMLElement
    , dispatchPatchTree :: PatchTree -> Effect Unit
    , outputHandlers    :: OutputHandlersList
    }

workLoop :: forall slots message. WorkLoopSpec slots message -> Effect (Unsubscribe)
workLoop { container, dispatchPatchTree, outputHandlers, eVNode } = do
  qDiffWork        <- Queue.new
  commitedVNodeRef <- Ref.new Nothing
  scheduler        <- mkScheduler

  let dispatchDiffWork = qDiffWork.dispatch
      mount vNode = do
        Ref.write (Just vNode) commitedVNodeRef
        void <<< requestAnimationFrame $ VirtualDom.mount { container, outputHandlers } vNode

  let finishDiffWork { rootVNode, rootPatchTree } = do
        Ref.write (Just rootVNode) commitedVNodeRef
        dispatchPatchTree rootPatchTree

  let environment = { finishDiffWork, dispatchDiffWork, scheduler }
      dispatchDiffWorkByVNode commitedVNode = dispatchDiffWork <<< VirtualDom.mkDiffWork commitedVNode
      f = maybe mount dispatchDiffWorkByVNode

  unsubscribeDiffWorkDispatch <- eVNode
    # subscribe \vNode -> Ref.read commitedVNodeRef >>= flip f vNode
  unsubscribeDiffWorkPerformance <- qDiffWork.event
    # debounceImmediate
    # subscribe (VirtualDom.performDiffWork environment)

  pure do
    unsubscribeDiffWorkDispatch
    unsubscribeDiffWorkPerformance
    unmount `whenJustM` Ref.read commitedVNodeRef

  where unmount = VirtualDom.unmount container
