module Monarch.Platform
  ( Platform
  , Command
  , Upstream
  , Effects
  , COMMAND
  , CommandF
  , mkPlatform
  , runPlatform
  , dispatch
  )
where

import Prelude

import Type.Row                                            as Row
import Run                    ( Run
                              , FProxy
                              , SProxy (..)
                              , EFFECT
                              , AFF
                              , runBaseAff'
                              , interpret
                              )
import Run                                                 as Run
import Effect                 ( Effect )
import Effect.Aff             ( Aff
                              , launchAff_
                              )
import Monarch.Behavior       ( Behavior
                              , step
                              , sample
                              )
import Monarch.Event          ( Event
                              , Unsubscribe
                              , scan
                              , subscribe
                              , distinctUntilRefChanged
                              )
import Monarch.Queue                                       as Queue
import Unsafe.Coerce          ( unsafeCoerce )

type Spec model message effects effects' r
  = { init         :: model
    , update       :: message -> model -> model
    , command      :: message -> model -> Command message effects
    , interpreter  :: forall a . Run effects a -> Run effects' a
    , subscription :: Upstream model message -> Event message
    | r
    }

type Platform model message
  = { dispatchMessage          :: message -> Effect Unit
    , bModel                   :: Behavior model
    , eModel                   :: Event model
    , eAff                     :: Event (Aff Unit)
    , eMessageFromSubscription :: Event message
    }

type Upstream model message
  = { bModel   :: Behavior model
    , eModel   :: Event model
    , eMessage :: Event message
    }

data CommandF message a = Dispatch message a

derive instance functorCommandF :: Functor (CommandF message)

_command = SProxy :: SProxy "command"

type COMMAND message = FProxy (CommandF message)

type Effects message r = (effect :: EFFECT, aff :: AFF, command :: COMMAND message | r)

type Command message r = Run (Effects message r) Unit

dispatch :: forall message r. message -> Run (command :: COMMAND message | r) Unit
dispatch message = Run.lift _command $ Dispatch message unit

runCommand :: forall message r
            . (message -> Effect Unit)
           -> Run (effect :: EFFECT, command :: COMMAND message | r) 
           ~> Run (effect :: EFFECT | r)
runCommand dispatchMessage = interpret (Run.on _command (handleCommand dispatchMessage) Run.send)

handleCommand :: forall message r
               . (message -> Effect Unit)
              -> CommandF message
              ~> Run (effect :: EFFECT | r)
handleCommand dispatchMessage = case _ of
  Dispatch message next -> Run.liftEffect $ dispatchMessage message *> pure next

mkPlatform :: forall model message effects s s' r
            . Row.Union s s' (Effects message ())
           => Spec model message effects s r
           -> Effect (Platform model message)
mkPlatform { init, update, command, interpreter, subscription } = do
  qMessage <- Queue.new
  let
    eModel = qMessage.event # scan update init
                            # distinctUntilRefChanged
    bModel = step init eModel
    run = runBaseAff' <<< runCommand qMessage.dispatch <<< unsafeCoerce interpreter
  pure
    { bModel
    , eModel
    , dispatchMessage: qMessage.dispatch
    , eAff: qMessage.event <#> command # sample bModel <#> run
    , eMessageFromSubscription: subscription { bModel, eModel, eMessage: qMessage.event }
    }

runPlatform :: forall model message. Platform model message -> Effect Unsubscribe
runPlatform { eAff, eMessageFromSubscription, dispatchMessage } = do
  -- Subscriptions
  unsubscribeCommand      <- eAff                     # subscribe launchAff_
  unsubscribeSubscription <- eMessageFromSubscription # subscribe dispatchMessage
  -- Unsubscribe
  pure $ unsubscribeSubscription *> unsubscribeCommand
  
