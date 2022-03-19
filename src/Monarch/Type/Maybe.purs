{-|
Module     : Monarch.Type.Maybe
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Type.Maybe
    ( module Data.Maybe
    , Nothing
    , Just
    ) where

import Data.Maybe (Maybe)

foreign import data Nothing :: forall a. Maybe a
foreign import data Just :: forall a. a -> Maybe a
