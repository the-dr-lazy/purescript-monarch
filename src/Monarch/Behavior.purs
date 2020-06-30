module Monarch.Behavior (module Monarch.Behavior) where

import Prelude
import Control.Plus
import Effect
import Monarch.Event (Event, sampleOn)

newtype Behavior a
  = Behavior (forall b. Event (a -> b) -> Event b)

instance functorBehavior :: Functor Behavior where
  map f (Behavior b) = Behavior (b <<< map (_ <<< f))

step :: forall a. a -> Event a -> Behavior a
step x e = Behavior (sampleOn (pure x <|> e))
