module Monarch.Platform
  ( Platform
  , Command
  , Source
  , mkPlatform
  , runPlatform
  )
where

import Prelude
import Data.Maybe
import Monarch.Monad.Maybe
import Effect 
import Effect.Class           ( liftEffect )
import Effect.Aff             ( Aff
                              , launchAff_
                              )
import Effect.Ref                                          as Ref
import Monarch.Behavior       ( Behavior
                              , step
                              )
import Monarch.Event          ( Event
                              , Unsubscribe
                              , scan
                              , subscribe
                              , distinctUntilRefChanged
                              )
import Monarch.Queue                                       as Queue
import Monarch.VirtualDOM     ( VirtualNode )
import Monarch.VirtualDOM                                  as VirtualDOM

type Spec model message r
  = { init :: model
    , update :: message -> model -> model
    , command :: message -> Command message
    , subscription :: Source model -> Event message
    | r
    }

type Platform model message
  = { dispatchMessage :: message -> Effect Unit
    , bModel :: Behavior model
    , eModel :: Event model
    , eCommand :: Event (Command message)
    , eMessageFromSubscription :: Event message
    }

type Source model = { bModel :: Behavior model, eModel :: Event model }

type Command message
  = Aff (Maybe message)

mkPlatform :: forall model message r. Spec model message r -> Effect (Platform model message)
mkPlatform { init, update, command, subscription } = do
  qMessage <- Queue.new
  let
    eModel = scan update qMessage.event init # distinctUntilRefChanged
    bModel = step init eModel
  pure
    { bModel
    , eModel
    , dispatchMessage: qMessage.dispatch
    , eCommand: qMessage.event <#> command
    , eMessageFromSubscription: subscription { bModel, eModel }
    }

runPlatform :: forall model message. Platform model message -> Effect Unsubscribe
runPlatform { eCommand, eMessageFromSubscription, dispatchMessage } = do
  -- Subscriptions
  unsubscribeCommand      <- eCommand                 # subscribe runCommand
  unsubscribeSubscription <- eMessageFromSubscription # subscribe dispatchMessage
  -- Unsubscribe
  pure $ unsubscribeCommand *> unsubscribeSubscription
  where runCommand = launchAff_ <<< whenJustM (liftEffect <<< dispatchMessage)
