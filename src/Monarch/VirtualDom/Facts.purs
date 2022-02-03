{-|
Module     : Monarch.VirtualDom.Facts
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.Facts
  ( class EventNameToOutputKey
  , class ExtractSlotNameFromFacts
  , Facts
  ) where

import Monarch.Type.Symbol as Symbol
import Monarch.VirtualDom.Slots as Slots
import Prim.Symbol as Symbol
import Type.Prelude
import Type.Row (type (+))
import Type.RowList as RowList

type OutputKeyPrefix = "on"

class EventNameToOutputKey :: Symbol -> Symbol -> Constraint
class EventNameToOutputKey event_name output_key

instance
  ( Symbol.TitleCase event_name output_tail
  , Symbol.Append OutputKeyPrefix output_tail output_key
  ) =>
  EventNameToOutputKey event_name output_key

class ExtractSlotNameFromFacts :: forall r. r Type -> Symbol -> Constraint
class ExtractSlotNameFromFacts facts slot_name | facts -> slot_name

instance ExtractSlotNameFromFacts RowList.Nil Slots.Default
else instance ExtractSlotNameFromFacts (RowList.Cons "name" (Proxy slot_name) _facts) slot_name
else instance (ExtractSlotNameFromFacts facts slot_name) => ExtractSlotNameFromFacts (RowList.Cons _name _t facts) slot_name
else instance (RowToList rfacts facts, ExtractSlotNameFromFacts facts slot_name) => ExtractSlotNameFromFacts rfacts slot_name

type Facts :: (Row Type -> Row Type) -> (Row Type -> Row Type) -> Row Type -> Row Type -> Row Type
type Facts properties outputs attributes hooks
  = properties
  + outputs
  + ( attributes :: { | attributes }
    , hooks      :: { | hooks }
    , key        :: forall key. key
    )
