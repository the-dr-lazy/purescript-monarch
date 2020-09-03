module Counter.Main (main) where

import Prelude

import Type.Row              ( type (+) )
import Run                   ( Run, EFFECT )
import Effect                ( Effect )
import Effect.Aff            ( launchAff_ )
import Web.HTML              ( HTMLElement )
import Monarch               ( Command, Upstream )
import Monarch                                   as Monarch
import Monarch.VirtualDOM
import Monarch.Event         ( Event
                             , eNever
                             )
import Counter.API           ( runAPI )
import Counter.API                               as API

type Input = Unit

type Model = Int

data Message = UserClickedIncreaseButton
             | UserClickedDecreaseButton

type Output = Void

init :: Model
init = 0

update :: Message -> Model -> Model
update = case _ of
  UserClickedIncreaseButton -> (_ + 1)
  UserClickedDecreaseButton -> (_ - 1)

view :: Model -> VirtualNode Message
view model = 
  div_ [ button { onClick: const UserClickedDecreaseButton } [ text "-" ]
       , text $ show model
       , button { onClick: const UserClickedIncreaseButton } [ text "+" ]
       ]

command :: Message
        -> Model
        -> Command (API.Effects ()) Message Output Unit
command message _ = case message of
  UserClickedIncreaseButton -> API.increase 
  UserClickedDecreaseButton -> API.decrease 

interpreter :: Command (API.Effects ()) Message Output Unit -> Command () Message Output Unit
interpreter = runAPI

subscription :: Upstream Input Model Message -> Event Message
subscription = const eNever

main :: HTMLElement -> Effect Unit
main container = do
  Monarch.document_ { input: unit
                    , init: const init
                    , update
                    , view
                    , command
                    , interpreter
                    , subscription
                    , container
                    }
