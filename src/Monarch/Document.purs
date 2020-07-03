module Monarch.Document (document) where

import Prelude
import Type.Row              ( type (+) )
import Type.Row                                          as Row
import Data.Maybe
import Record                                            as Record
import Effect
import Effect.Aff            ( Aff
                             , makeAff
                             , effectCanceler
                             )
import Effect.Ref            ( Ref )
import Effect.Ref                                        as Ref
import Web.HTML              ( HTMLElement )
import Monarch.Event         ( Event
                             , Unsubscribe
                             , eNever
                             , debounceIdleCallback
                             , debounceAnimationFrame    
                             , subscribe
                             )
import Monarch.Platform
import Monarch.Queue                                     as Queue
import Monarch.VirtualDOM    ( VirtualNode )
import Monarch.VirtualDOM                                as VirtualDOM
import Unsafe.Coerce         ( unsafeCoerce )

type OptionalSpec model message r
  = ( command :: message -> Command message
    , subscription :: Source model -> Event message
    | r
    )

type RequiredSpec model message r
  = ( init :: model
    , update :: message -> model -> model
    , view :: model -> VirtualNode message
    , element :: HTMLElement
    | r
    )

type Spec model message = RequiredSpec model message + OptionalSpec model message + ()

swap :: forall a. (a -> Effect Unit) -> (a -> a -> Effect Unit) -> Event a -> Effect Unsubscribe
swap mount patch e = do
  xRef <- Ref.new Nothing
  e # subscribe \x -> do
    Ref.read xRef >>= flip f x
    Ref.write (Just x) xRef
  where f = maybe mount patch

defaultSpec :: forall model message. { | OptionalSpec model message + () }
defaultSpec = { command: const $ pure Nothing, subscription: const eNever }

document' :: forall model message. Record (Spec model message) -> Effect Unsubscribe
document' spec@{ view, element } = do
  qVirtualNode                         <- Queue.new
  platform@{ eModel, dispatchMessage } <- mkPlatform spec

  let mount = VirtualDOM.mount dispatchMessage element
      patch = VirtualDOM.patch dispatchMessage
      
  -- Subscriptions
  unsubscribeRender <- eModel
    # debounceIdleCallback
    # subscribe (qVirtualNode.dispatch <<< view)
  unsubscribeCommit <- qVirtualNode.event
    # debounceAnimationFrame
    # swap mount patch
  unsubscribePlatform <- runPlatform platform

  -- Unsubscribe
  pure do
    unsubscribePlatform
    unsubscribeCommit
    unsubscribeRender

document :: forall model message spec spec'
          . Row.Union spec spec' (OptionalSpec model message + ())
         => { | RequiredSpec model message + spec } 
         -> Aff Unit
document spec = makeAff \_ -> do
  unsubscribe <- document' (Record.union spec $ unsafeCoerce defaultSpec)
  pure $ effectCanceler unsubscribe
             
             
