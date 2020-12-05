{-|
Module     : Monarch.Platform
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

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

type Spec input model message output effects a r
  = ( input        :: input
    , init         :: input -> model
    , update       :: message -> model -> model
    , command      :: message -> model -> Run effects a
    , interpreter  :: Run effects a -> Run (Effects message output ()) Unit
    , subscription :: Upstream input model message -> Event message
    | r
    )

type Platform input model message output
  = { bModel          :: Behavior model
    , eModel          :: Event model
    , eOutput         :: Event output
    , sCommand        :: Effect Unsubscribe
    , sSubscription   :: Effect Unsubscribe
    , dispatchMessage :: message -> Effect Unit
    , dispatchInput   :: input -> Effect Unit
    }

type Upstream input model message
  = { eInput   :: Event input
    , bModel   :: Behavior model
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

mkPlatform :: forall input model message output effects a r
            . { | Spec input model message output effects a r }
           -> Effect (Platform input model message output)
mkPlatform { input, init, update, command, interpreter, subscription } = do
  qInput   <- Queue.new
  qMessage <- Queue.new
  qOutput  <- Queue.new
  let
    initialModel    = init input
    eInput          = qInput.event
    eMessage        = qMessage.event
    eOutput         = qOutput.event
    eModel          = eMessage # scan update initialModel
                               # distinctUntilRefChanged
    bModel          = step initialModel eModel
    dispatchInput   = qInput.dispatch
    dispatchMessage = qMessage.dispatch
    dispatchOutput  = qOutput.dispatch
    run             = launchAff_ <<< runBaseAff' <<< runCommand dispatchMessage dispatchOutput <<< interpreter
    upstream        = { eInput, bModel, eModel, eMessage }
  pure
    { bModel
    , eModel
    , eOutput
    , dispatchMessage
    , dispatchInput
    , sCommand: eMessage <#> command
                          #  sample bModel
                          #  subscribe run
    , sSubscription: subscription upstream # subscribe dispatchMessage
    }

runPlatform :: forall input model message output. Platform input model message output -> Effect Unsubscribe
runPlatform { sCommand, sSubscription } = do
  -- Subscriptions
  unsubscribeCommand      <- sCommand
  unsubscribeSubscription <- sSubscription
  -- Unsubscribe
  pure $ unsubscribeSubscription *> unsubscribeCommand
