{-|
Module     : Monarch.Behavior
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

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

sample :: forall a b. Behavior a -> Event (a -> b) -> Event b
sample (Behavior b) e = b e
