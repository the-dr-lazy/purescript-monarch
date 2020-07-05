module Counter.Main (main) where

import Prelude

import Data.Maybe            ( Maybe (..) )
import Effect                ( Effect )
import Effect.Aff            ( Aff, launchAff_ )
import Monarch                                      as Monarch
import Monarch.VirtualDOM  
import Web.HTML              ( HTMLElement )
import Counter.API                                  as API

type Model = Int

data Message = Increase
             | Decrease

init :: Model
init = 0

update :: Message -> Model -> Model
update Increase = (_ + 1)
update Decrease = (_ - 1)

view :: Model -> VirtualNode Message
view model = 
  h_ "div"
     [ h "button" { on: { click: (\_ -> Decrease) } } [ text "-" ]
     , text $ show model
     , h "button" { on: { click: (\_ -> Increase) } } [ text "+" ]
     ]

command :: Message -> Aff (Maybe Message)
command Increase = API.increase *> pure Nothing
command Decrease = API.decrease *> pure Nothing

main :: HTMLElement -> Effect Unit
main container = launchAff_ $
  Monarch.document { init
                   , update
                   , view
                   , command
                   , container
                   }

