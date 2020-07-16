module Monarch.Document
  ( OptionalSpec
  , RequiredSpec
  , Spec
  , document
  , document_
  )
where

import Prelude

import Type.Row              ( type (+) )
import Type.Row                                          as Row
import Data.Maybe
import Run                   ( Run )
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
                             , Command
                             , Upstream
                             , Effects
                             , mkPlatform
                             , runPlatform
                             )
import Monarch.Queue         ( Queue )
import Monarch.Queue                                     as Queue
import Monarch.VirtualDOM    ( VirtualNode )
import Monarch.VirtualDOM                                as VirtualDOM
import Monarch.Monad.Maybe   ( whenJustM )
import Unsafe.Coerce         ( unsafeCoerce )

-- | Document's optional input specification
type OptionalSpec model message output effects effects' r
  = ( command      :: message -> model -> Command message output effects
    , interpreter  :: forall a . Run effects a -> Run effects' a
    , subscription :: Upstream model message -> Event message
    | r
    )

-- | Document's minimal required input specification
type RequiredSpec model message r
  = ( init      :: model
    , update    :: message -> model -> model
    , view      :: model -> VirtualNode message
    , container :: HTMLElement
    | r
    )

-- | Document's full input specification
type Spec model message output effects effects'
  = RequiredSpec model message
  + OptionalSpec model message output effects effects' ()

type Document model message output
  = { platform :: Platform model message output
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

mkDocument :: forall model message output effects e e'
            . Row.Union e e' (Effects message output ())
           => { | Spec model message output effects e }
           -> Effect (Document model message output)
mkDocument spec@{ view, container } = do
  qVirtualNode                         <- Queue.new
  platform@{ eModel, dispatchMessage } <- mkPlatform spec
  let
    render = qVirtualNode.dispatch <<< view
    mount = VirtualDOM.mount dispatchMessage container
    patch = VirtualDOM.patch dispatchMessage
  pure
    { platform
    , sRender: eModel # debounceIdleCallback
                      # subscribe render
    , sCommit: qVirtualNode.event # debounceAnimationFrame
                                  # swap mount patch VirtualDOM.unmount
    }

runDocument :: forall model message output. Document model message output -> Effect Unsubscribe
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

type Document' output
  = { unsubscribe :: Effect Unit
    , eOutput     :: Event output
    }

document :: forall model message output effects e e'
          . Row.Union e e' (Effects message output ())
         => { | Spec model message output effects e }
         -> Effect (Document' output)
document spec = do
  d@{ platform } <- mkDocument spec
  unsubscribe <- runDocument d
  pure { unsubscribe, eOutput: platform.eOutput }

document_ :: forall model message output effects e e'
          . Row.Union e e' (Effects message output ())
         => { | Spec model message output effects e }
         -> Effect Unit
document_ = void <<< document
