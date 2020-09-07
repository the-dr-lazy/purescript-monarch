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
                             , debounceIdleCallback
                             , debounceAnimationFrame
                             , subscribe
                             )
import Monarch.Platform      ( Platform
                             , mkPlatform
                             , runPlatform
                             )
import Monarch.Platform                                  as Platform
import Monarch.Queue                                     as Queue
import Monarch.Html    ( Html )
import Monarch.VirtualDom as VirtualDom
import Monarch.Monad.Maybe   ( whenJustM )

-- | Document's full input specification
type Spec input model message output effects a r
  = Platform.Spec input model message output effects a
  + ( view      :: model -> Html message
    , container :: HTMLElement
    | r
    )

type Document input model message output
  = { platform :: Platform input model message output
    , sRender  :: Effect Unsubscribe
    , sCommit  :: Effect Unsubscribe
    }

swap :: forall a. (a -> Effect Unit) -> (a -> a -> Effect Unit) -> (a -> Effect Unit) -> Event a -> Effect Unsubscribe
swap mount patch unmount e = do
  xRef <- Ref.new Nothing
  unsubscribe <- e # subscribe \x -> do
    Ref.read xRef >>= flip f x
    Ref.write (Just x) xRef
  pure do
    unsubscribe
    unmount `whenJustM` Ref.read xRef
  where f = maybe mount patch

mkDocument :: forall input model message output effects a r
            . { | Spec input model message output effects a r }
           -> Effect (Document input model message output)
mkDocument spec@{ view, container } = do
  qVirtualNode <- Queue.new
  platform@{ eModel, dispatchMessage } <- mkPlatform spec
  let
    render = qVirtualNode.dispatch <<< view
    mount = VirtualDom.mount dispatchMessage container
    patch = VirtualDom.patch dispatchMessage
  pure
    { platform
    , sRender: eModel # debounceIdleCallback
                      # subscribe render
    , sCommit: qVirtualNode.event # debounceAnimationFrame
                                  # swap mount patch VirtualDom.unmount
    }

runDocument :: forall input model message output. Document input model message output -> Effect Unsubscribe
runDocument { sRender, sCommit, platform } = do
  -- Subscriptions
  unsubscribeRender   <- sRender
  unsubscribeCommit   <- sCommit
  unsubscribePlatform <- runPlatform platform
  -- Unsubscribe
  pure do
    unsubscribePlatform
    unsubscribeCommit
    unsubscribeRender

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
document_ = void <<< document
