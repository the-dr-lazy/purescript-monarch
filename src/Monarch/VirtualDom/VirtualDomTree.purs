{-|
Module     : Monarch.VirtualDom.VirtualDomTree
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.VirtualDomTree
  ( VirtualDomTree
  , Node
  , Leaf
  , class ExtractKeyType
  , class ExtractKeyType'
  , text
  , keyed
  )
where

import Prelude
import Data.Symbol
import Monarch.Type.Maybe
import Monarch.Type.Row as Row
import Monarch.VirtualDom.Facts
import Monarch.VirtualDom.Facts.Hooks
import Monarch.Type.Row                                    as Row
import Monarch.Type.Maybe
import Type.Prelude
import Type.RowList (RowList)
import Type.RowList as RowList
import Type.Row as Row
import Monarch.VirtualDom.Slots as Slots

foreign import data VirtualDomTree
  :: Symbol     -- ^ Substituted slot
  -> Row Type   -- ^ Downstream slots
  -> Row Type   -- ^ Global facts extension
  -> Maybe Type -- ^ Key
  -> Type       -- ^ Message
  -> Type

foreign import fmapVirtualDomTree
  :: forall substituted_slot downstream_slots facts_r key a b
   . (a -> b)
  -> VirtualDomTree substituted_slot downstream_slots facts_r key a
  -> VirtualDomTree substituted_slot downstream_slots facts_r key b

instance Functor (VirtualDomTree substituted_slot downstream_slots facts_r key) where
  map = fmapVirtualDomTree

-- Hyperscript

type Node :: (Row Type -> Row Type) -> (Type -> Row Type -> Row Type) -> (Row Type -> Row Type) -> Type
type Node mk_properties mk_outputs mk_attributes
  = forall facts facts_r _facts key _key _child_key attributes hooks substituted_slot downstream_slots message
  . Row.Union facts _facts (Facts mk_properties (mk_outputs message) attributes hooks _key facts_r)
 => Row.OptionalRecordCons facts "attrs" (mk_attributes ()) attributes
 => Row.OptionalRecordCons facts "hooks" (Hooks message) hooks
 => ExtractKeyType facts key
 => { | facts }
 -> Array (VirtualDomTree Slots.Default downstream_slots facts_r _child_key message)
 -> VirtualDomTree substituted_slot downstream_slots facts_r key message

type Leaf :: (Row Type -> Row Type) -> (Type -> Row Type -> Row Type) -> (Row Type -> Row Type) -> Type
type Leaf mk_properties mk_outputs mk_attributes
  = forall facts facts_r _facts key _key attributes hooks substituted_slot downstream_slots message
  . Row.Union facts _facts (Facts mk_properties (mk_outputs message) attributes hooks _key facts_r)
 => Row.OptionalRecordCons facts "attrs" (mk_attributes ()) attributes
 => Row.OptionalRecordCons facts "hooks" (Hooks message) hooks
 => ExtractKeyType facts key
 => { | facts }
 -> VirtualDomTree substituted_slot downstream_slots facts_r key message

foreign import text :: forall downstream_slots facts_r message. String -> VirtualDomTree Slots.Default downstream_slots facts_r Nothing message

foreign import keyed
  :: forall substituted_slot downstream_slots facts_r key message
   . key
  -> VirtualDomTree substituted_slot downstream_slots facts_r Nothing    message
  -> VirtualDomTree substituted_slot downstream_slots facts_r (Just key) message

class ExtractKeyType (row :: Row Type) (key :: Maybe Type) | row -> key

instance (RowToList row list, ExtractKeyType' list key) => ExtractKeyType row key

class ExtractKeyType' (row :: RowList Type) (key :: Maybe Type) | row -> key

instance ExtractKeyType' RowList.Nil Nothing

instance ExtractKeyType' (RowList.Cons "key" a _tail) (Just a)
else instance (ExtractKeyType' tail key) => ExtractKeyType' (RowList.Cons _name _t tail) key
