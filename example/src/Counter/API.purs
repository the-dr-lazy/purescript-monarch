{-|
Module     : Counter.API
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Counter.API (COUNTER, CounterF, increase, decrease, runCounter, run) where

import Prelude

import Run
    ( Run
    , EFFECT
    , interpret
    )
import Run as Run
import Effect.Console as Console
import Type.Row (type (+))
import Type.Proxy

data CounterF a
    = Increase a
    | Decrease a

derive instance Functor CounterF

type COUNTER r = (counter :: CounterF | r)

_counter :: Proxy "counter"
_counter = Proxy

increase :: forall r. Run (COUNTER + r) Unit
increase = Run.lift _counter $ Increase unit

decrease :: forall r. Run (COUNTER + r) Unit
decrease = Run.lift _counter $ Decrease unit

runCounter :: forall r. Run (COUNTER + EFFECT + r) ~> Run (EFFECT + r)
runCounter = interpret (Run.on _counter handleCounter Run.send)

handleCounter :: forall r. CounterF ~> Run (EFFECT + r)
handleCounter = case _ of
    Increase next -> do
        Run.liftEffect $ Console.log "increase requested"
        pure next
    Decrease next -> do
        Run.liftEffect $ Console.log "decrease requested"
        pure next

run :: forall r. Run (COUNTER + EFFECT + r) ~> Run (EFFECT + r)
run = runCounter
