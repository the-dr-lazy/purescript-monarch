{-|
Module     : Monarch.Monad.Maybe
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Monad.Maybe where

import Prelude
import Data.Maybe

whenJust :: forall f a. Applicative f => (a -> f Unit) -> Maybe a -> f Unit
whenJust f (Just x) = f x
whenJust _ Nothing  = pure unit

whenJustM :: forall m a. Monad m => (a -> m Unit) -> m (Maybe a) -> m Unit
whenJustM f mm = mm >>= whenJust f
