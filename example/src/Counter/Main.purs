module Counter.Main (main) where

import Prelude

import Run                   ( Run, EFFECT )
import Effect                ( Effect )
import Effect.Aff            ( launchAff_ )
import Web.HTML              ( HTMLElement )    
import Monarch               ( Command )
import Monarch                                   as Monarch
import Monarch.VirtualDOM    
import Monarch.Event         ( Event
                             , eNever
                             )
import Counter.API           ( runAPI )
import Counter.API                               as API

type Model = Int

data Message = Increase
             | Decrease

init :: Model
init = 0

update :: Message -> Model -> Model
update = case _ of
  Increase -> (_ + 1)
  Decrease -> (_ - 1)

view :: Model -> VirtualNode Message
view model = 
  h_ "div"
     [ h "button" { on: { click: (\_ -> Decrease) } } [ text "-" ]
     , text $ show model
     , h "button" { on: { click: (\_ -> Increase) } } [ text "+" ]
     ]

command :: Message
        -> Model
        -> Command Message (API.Effects ())
command Increase _ = API.increase 
command Decrease _ = API.decrease 

interpreter :: forall r. Run (API.Effects r) ~> Run (effect :: EFFECT | r)
interpreter = runAPI

subscription :: forall a. a -> Event Message
subscription = const eNever

main :: HTMLElement -> Effect Unit
main container = launchAff_ $
  Monarch.document { init
                   , update
                   , view
                   , command
                   , interpreter
                   , subscription
                   , container
                   }
  

