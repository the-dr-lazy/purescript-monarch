{-|
Module     : Monarch.Html.Attributes
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Html.Attributes where

import Prelude

import Type.Row    ( type (+) )

-- | A wrapper for strings which are used as CSS classes.
newtype ClassName = ClassName String

derive newtype instance eqClassName :: Eq ClassName
derive newtype instance ordClassName :: Ord ClassName
derive newtype instance semigroupClassName :: Semigroup ClassName

type GlobalAttributes r
  = ( class   :: ClassName       -- | Assigning class(es) to an element
    , classes :: Array ClassName -- | Assigning classes to an element
    | r
    )

type HTMLDivElementAttributes r = GlobalAttributes r

type HTMLButtonElementAttributes r
  = GlobalAttributes
  + ( autofocus :: Boolean -- | Automatically focus the form control when the page is loaded
    , disabled  :: Boolean -- | Whether the form control is disabled
    | r
    )
