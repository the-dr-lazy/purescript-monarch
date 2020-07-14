module Counter.API where

import Prelude

import Run               ( Run
                         , FProxy
                         , SProxy (..)
                         , EFFECT
                         , interpret
                         )
import Run                              as Run
import Effect.Console                   as Console

data CounterF a = Increase a
                | Decrease a

derive instance functorCounterF :: Functor CounterF

type COUNTER = FProxy CounterF

_counter :: SProxy "counter"
_counter = SProxy

increase :: forall r. Run (counter :: COUNTER | r) Unit
increase = Run.lift _counter $ Increase unit

decrease :: forall r. Run (counter :: COUNTER | r) Unit
decrease = Run.lift _counter $ Decrease unit

runCounterAPI :: forall r. Run (effect :: EFFECT, counter :: COUNTER | r) ~> Run (effect :: EFFECT | r)
runCounterAPI = interpret (Run.on _counter handleCounterAPI Run.send)

handleCounterAPI :: forall r. CounterF ~> Run (effect :: EFFECT | r)
handleCounterAPI = case _ of
  Increase next -> do
    Run.liftEffect $ Console.log "increase requested"
    pure next
  Decrease next -> do
    Run.liftEffect $ Console.log "decrease requested"
    pure next


type Effects r = (effect :: EFFECT, counter :: COUNTER | r)

runAPI :: forall r. Run (Effects r) ~> Run (effect :: EFFECT | r)
runAPI = runCounterAPI
