module Monarch.Document
  ( OptionalSpec
  , RequiredSpec
  , Spec
  , document
  )
where

import Prelude

import Type.Row              ( type (+) )
import Type.Row                                          as Row
import Data.Maybe
import Run                   ( Run )
import Effect                ( Effect )
import Effect.Aff            ( Aff
                             , makeAff
                             , effectCanceler
                             )
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
type OptionalSpec model message effects effects' r
  = ( command      :: message -> model -> Command message effects
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
type Spec model message effects effects'
  = RequiredSpec model message
  + OptionalSpec model message effects effects' ()

type Document model message
  = { qVirtualNode :: Queue (VirtualNode message)
    , platform     :: Platform model message
    , view         :: model -> VirtualNode message
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

mkDocument :: forall model message effects e e'
            . Row.Union e e' (Effects message ())
           => { | Spec model message effects e } 
           -> Effect (Document model message)
mkDocument spec@{ view } = do
  qVirtualNode                         <- Queue.new
  platform@{ eModel, dispatchMessage } <- mkPlatform spec

  pure { qVirtualNode, platform, view }

runDocument :: forall model message. HTMLElement -> Document model message -> Effect Unsubscribe
runDocument container { qVirtualNode, platform, view } = do
  let { eModel, dispatchMessage } = platform

  let mount = VirtualDOM.mount dispatchMessage container
      patch = VirtualDOM.patch dispatchMessage

  -- Subscriptions
  unsubscribeRender <- eModel
    # debounceIdleCallback
    # subscribe (qVirtualNode.dispatch <<< view)
  unsubscribeCommit <- qVirtualNode.event
    # debounceAnimationFrame
    # swap mount patch VirtualDOM.unmount
  unsubscribePlatform <- runPlatform platform

  -- Unsubscribe
  pure do
    unsubscribePlatform
    unsubscribeCommit
    unsubscribeRender

document :: forall model message effects e e' 
          . Row.Union e e' (Effects message ())
         => { | Spec model message effects e } 
         -> Aff Unit
document spec@{ container } = makeAff \_ -> do
  unsubscribe <- runDocument container =<< mkDocument spec
  pure $ effectCanceler unsubscribe
