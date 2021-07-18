module Monarch.Command
  ( Command
  , BASIC
  , COMMAND
  , CommandF
  , dispatch
  , raise
  , mkCommandRunner
  )
where

import Prelude
import Type.Proxy
import Type.Row (type (+))
import Run                    ( Run
                              , EFFECT
                              , AFF
                              , runBaseAff'
                              , interpret
                              )
import Run                                                 as Run
import Effect                 ( Effect )
import Effect.Aff             ( launchAff_
                              )


data CommandF message output a
  = Dispatch message a
  | Raise output a

derive instance functorCommandF :: Functor (CommandF message output)

_command = Proxy :: Proxy "command"

type COMMAND message output r = (command :: CommandF message output | r)

type BASIC message output r
  = EFFECT
  + AFF
  + COMMAND message output
  + r

type Command effects message output = Run (BASIC message output effects)

dispatch :: forall message output r. message -> Run (COMMAND message output + r) Unit
dispatch message = Run.lift _command $ Dispatch message unit

raise :: forall message output r. output -> Run (COMMAND message output + r) Unit
raise output = Run.lift _command $ Raise output unit

runCommand :: forall message output r
            . (message -> Effect Unit)
           -> (output -> Effect Unit)
           -> Run (COMMAND message output + EFFECT + r)
           ~> Run (EFFECT + r)
runCommand dispatchMessage dispatchOutput = interpret (Run.on _command (handleCommand dispatchMessage dispatchOutput) Run.send)

handleCommand :: forall message output r
              . (message -> Effect Unit)
             -> (output -> Effect Unit)
             -> CommandF message output
             ~> Run (EFFECT + r)
handleCommand dispatchMessage dispatchOutput = case _ of
  Dispatch message next -> Run.liftEffect $ dispatchMessage message *> pure next
  Raise    output  next -> Run.liftEffect $ dispatchOutput output   *> pure next

mkCommandRunner :: forall message model output effects a
                 . (message -> model -> Run effects a)
                -> (Run effects a -> Run (BASIC message output ()) Unit)
                -> { dispatchMessage :: message -> Effect Unit, dispatchOutput :: output -> Effect Unit }
                -> { message :: message, model :: model }
                -> Effect Unit
mkCommandRunner command interpreter { dispatchMessage, dispatchOutput } { message, model } =
  launchAff_ <<< runBaseAff' <<< runCommand dispatchMessage dispatchOutput <<< interpreter $ command message model
