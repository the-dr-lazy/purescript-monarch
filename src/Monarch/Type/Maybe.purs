{-|
Module     : Monarch.Type.Maybe
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Type.Maybe where

foreign import kind Maybe

foreign import data Nothing :: Maybe

foreign import data Just :: Type -> Maybe
