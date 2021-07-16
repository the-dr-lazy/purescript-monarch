module Monarch.Command
  ( Command
  , BASIC
  , COMMAND
  , CommandF
  , dispatch
  , run
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


data CommandF message a
  = Dispatch message a

derive instance functorCommandF :: Functor (CommandF message)

_command = Proxy :: Proxy "command"

type COMMAND message r = (command :: CommandF message | r)

type BASIC message r
  = EFFECT
  + AFF
  + COMMAND message
  + r

type Command effects message = Run (BASIC message effects)

dispatch :: forall message r. message -> Run (COMMAND message + r) Unit
dispatch message = Run.lift _command $ Dispatch message unit

runCommand :: forall message r
            . (message -> Effect Unit)
           -> Run (COMMAND message + EFFECT + r)
           ~> Run (EFFECT + r)
runCommand dispatchMessage = interpret (Run.on _command (handleCommand dispatchMessage) Run.send)

handleCommand :: forall message r
              . (message -> Effect Unit)
             -> CommandF message
             ~> Run (EFFECT + r)
handleCommand dispatchMessage  = case _ of
  Dispatch message next -> Run.liftEffect $ dispatchMessage message *> pure next

run :: forall message model effects a
    . (message -> model -> Run effects a)
    -> (Run effects a -> Run (BASIC message ()) Unit)
    -> message
    -> model
    -> (message -> Effect Unit)
    -> Effect Unit
run command interpreter message model dispatchMessage =
  launchAff_ <<< runBaseAff' <<< runCommand dispatchMessage <<< interpreter $ command message model
