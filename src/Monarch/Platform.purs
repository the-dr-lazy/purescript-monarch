module Monarch.Platform
  ( Spec
  , Platform
  , Command
  , Upstream
  , Effects
  , COMMAND
  , CommandF
  , mkPlatform
  , runPlatform
  , dispatch
  , raise
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
                              , subscribe'
                              , distinctUntilRefChanged
                              )
import Monarch.Queue                                       as Queue
import Unsafe.Coerce          ( unsafeCoerce )

type Spec model message output effects a r
  = ( init         :: model
    , update       :: message -> model -> model
    , command      :: message -> model -> Run effects a
    , interpreter  :: Run effects a -> Run (Effects message output ()) Unit
    , subscription :: Upstream model message -> Event message
    | r
    )

type Platform model message output
  = { bModel          :: Behavior model
    , eModel          :: Event model
    , eOutput         :: Event output
    , sCommand        :: Effect Unsubscribe
    , sSubscription   :: Effect Unsubscribe
    , dispatchMessage :: message -> Effect Unit
    }

type Upstream model message
  = { bModel   :: Behavior model
    , eModel   :: Event model
    , eMessage :: Event message
    }

data CommandF message output a
  = Dispatch message a
  | Raise output a

derive instance functorCommandF :: Functor (CommandF message output)

_command = SProxy :: SProxy "command"

type COMMAND message output = FProxy (CommandF message output)

type Effects message output r
  = ( effect  :: EFFECT
    , aff     :: AFF
    , command :: COMMAND message output
    | r
    )

type Command effects message output a = Run (Effects message output effects) a

dispatch :: forall message output r. message -> Run (command :: COMMAND message output | r) Unit
dispatch message = Run.lift _command $ Dispatch message unit

raise :: forall message output r. output -> Run (command :: COMMAND message output | r) Unit
raise output = Run.lift _command $ Raise output unit

runCommand :: forall message output r
            . (message -> Effect Unit)
           -> (output -> Effect Unit)
           -> Run (effect :: EFFECT, command :: COMMAND message output | r) 
           ~> Run (effect :: EFFECT | r)
runCommand dispatchMessage dispatchOutput = interpret (Run.on _command (handleCommand dispatchMessage dispatchOutput) Run.send)

handleCommand :: forall message output r
               . (message -> Effect Unit)
              -> (output -> Effect Unit)
              -> CommandF message output
              ~> Run (effect :: EFFECT | r)
handleCommand dispatchMessage dispatchOutput = case _ of
  Dispatch message next -> Run.liftEffect $ dispatchMessage message *> pure next
  Raise    output  next -> Run.liftEffect $ dispatchOutput output   *> pure next

mkPlatform :: forall model message output effects a r
            . { | Spec model message output effects a r }
           -> Effect (Platform model message output)
mkPlatform { init, update, command, interpreter, subscription } = do
  qMessage <- Queue.new
  qOutput  <- Queue.new
  let
    eMessage        = qMessage.event
    eOutput         = qOutput.event
    eModel          = eMessage # scan update init
                               # distinctUntilRefChanged
    bModel          = step init eModel
    dispatchMessage = qMessage.dispatch
    dispatchOutput  = qOutput.dispatch
    run             = launchAff_ <<< runBaseAff' <<< runCommand dispatchMessage dispatchOutput <<< interpreter
    upstream        = { bModel, eModel, eMessage }
  pure
    { bModel
    , eModel
    , eOutput
    , dispatchMessage
    , sCommand: eMessage <#> command
                          #  sample bModel
                          #  subscribe run
    , sSubscription: subscription upstream # subscribe dispatchMessage
    }

runPlatform :: forall model message output. Platform model message output -> Effect Unsubscribe
runPlatform { sCommand, sSubscription } = do
  -- Subscriptions
  unsubscribeCommand      <- sCommand
  unsubscribeSubscription <- sSubscription
  -- Unsubscribe
  pure $ unsubscribeSubscription *> unsubscribeCommand
