module Main ( main ) where

import Prelude
import Data.Maybe
import Effect
import Effect.Aff            ( launchAff_ )
import Monarch.VirtualDOM
import Monarch                                 as Monarch
import API                                     as API
import Utils

type Model = Int

data Message
  = Increment 
  | Decrement 

init :: Model
init = 0

update :: Message -> Model -> Model
update Increment = (_ + 1)
update Decrement = (_ - 1)

list :: Model -> Array (VirtualNode Message)
list = Array.mapWithIndex \ix x ->
  h_ "div"

view :: Model -> VirtualNode Message
view model =
  h_ "div"
     [ h "button" { on: { click: const $ Decrement } } [ text "-" ]
     , text $ show model
     , h "button" { on: { click: const $ Increment } } [ text "+" ]
     ]

command :: Message -> Aff (Maybe Message)
command Increment = API.increment *> mempty
command Decrement = API.decrement *> mempty

subscription :: Source Model -> Event Message
subscription _ = interval 1000 $> Increment

main :: Effect Unit
main = launchAff_ do
  element <- awaitBody
  Monarch.document { init
                   , update
                   , view
                   , command
                   , subscription
                   , element
                   }
