{-|
Module     : Monarch.Type.RowList
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Type.RowList where

import Type.Row as Row
import Type.RowList as RowList
import Type.RowList (RowList)

-- | `RowList` version of `OptionalRecordCons` typeclass
class OptionalRecordCons (row :: RowList Type) (name :: Symbol) (s :: Row Type) (t :: Row Type)

instance OptionalRecordCons RowList.Nil _name _s _t
-- | Constraint target field (`name`) when it exists on given `row`
instance
    ( Row.Union t _t s
    ) =>
    OptionalRecordCons (RowList.Cons name { | t } tail) name s t
else instance
    ( OptionalRecordCons tail name s t
    ) =>
    OptionalRecordCons (RowList.Cons _name _t tail) name s t
