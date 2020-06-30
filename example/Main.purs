module Main ( main ) where

import Prelude
import Data.Maybe
import Data.Array                   as Array
import Effect
import Effect.Aff ( launchAff_ )
import Monarch.VirtualDOM
import Monarch                      as Monarch
import Utils

type Model
  = Array Int

data Message
  = Add
  | Increment Int
  | Decrement Int

init :: Model
init = []

modifyAt :: forall a. Int -> (a -> a) -> Array a -> Array a
modifyAt ix f xs = fromMaybe xs $ Array.modifyAt ix f xs

update :: Message -> Model -> Model
update Add = flip Array.snoc 0
update (Increment ix) = modifyAt ix (_ + 1)
update (Decrement ix) = modifyAt ix (_ - 1)

list :: Model -> Array (VirtualNode Message)
list = Array.mapWithIndex \ix x ->
  h_ "div"
     [ h "button" { on: { click: const $ Decrement ix } } [ text "-" ]
     , text $ show x
     , h "button" { on: { click: const $ Increment ix } } [ text "+" ]
     ]

view :: Model -> VirtualNode Message
view model =
  h_ "div"
     [ h "button" { on: { click: const $ Add } } [ text "add" ]
     , h_ "div" $ list model
     ]

main :: Effect Unit
main = launchAff_ do
  element <- awaitBody
  Monarch.document { init
                   , update
                   , view
                   , element
                   }
