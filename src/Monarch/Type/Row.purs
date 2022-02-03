{-|
Module     : Monarch.Type.Row
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Type.Row where

import Type.RowList (class RowToList)
import Monarch.Type.RowList as RowList

-- | Adds an optional record constraint with type `s` for field `name` to the given `row` type
class OptionalRecordCons (row :: Row Type) (name :: Symbol) (s :: Row Type) (t :: Row Type)

instance (RowToList row list, RowList.OptionalRecordCons list name s t) => OptionalRecordCons row name s t
