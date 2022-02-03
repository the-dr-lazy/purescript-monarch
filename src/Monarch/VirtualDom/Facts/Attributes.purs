{-|
Module     : Monarch.VirtualDom.Facts.Attributes
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.Facts.Attributes where

import Prelude
import Data.Newtype

-- | A wrapper for strings which are used as CSS classes.
newtype ClassName = ClassName String

derive newtype instance Eq ClassName
derive newtype instance Ord ClassName
derive newtype instance Semigroup ClassName

type GlobalAttributes r =
    ( class :: ClassName -- | Assigning class(es) to an element
    | r
    )
