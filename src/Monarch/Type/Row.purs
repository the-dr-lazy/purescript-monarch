{-|
Module     : Monarch.Type.Row
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Type.Row where

import Type.Prelude
import Type.RowList as RowList
import Type.Row as Row

-- | Adds an optional record constraint with type `s` for field `name` to the given `row` type
class OptionalRecordCons :: forall r. r Type -> Symbol -> Row Type -> Row Type -> Constraint
class OptionalRecordCons row name s t

instance OptionalRecordCons RowList.Nil _name _s _t
-- | Constraint target field (`name`) when it exists on given `row`
else instance
  ( Row.Union t _t s ) =>
  OptionalRecordCons (RowList.Cons name { | t } _tail) name s t
else instance
  (OptionalRecordCons tail name s t) => OptionalRecordCons (RowList.Cons _name _t tail) name s t
-- | `Row` to `RowList` conversion of the `row`
else instance
  (RowToList row list, OptionalRecordCons list name s t) => OptionalRecordCons row name s t
