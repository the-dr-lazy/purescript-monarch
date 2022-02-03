{-|
Module     : Monarch.VirtualDom.VirtualDomTree
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.VirtualDomTree
  ( VirtualDomTree
  , Node
  , Leaf
  , Slot
  , class ExtractKeyType
  , class ExtractKeyType'
  , text
  , keyed
  , node
  , leaf
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
  -> Maybe Type -- ^ Key
  -> Type       -- ^ Message
  -> Type

foreign import fmapVirtualDomTree
  :: forall substituted_slot downstream_slots key a b
   . (a -> b)
  -> VirtualDomTree substituted_slot downstream_slots key a
  -> VirtualDomTree substituted_slot downstream_slots key b

instance Functor (VirtualDomTree substituted_slot downstream_slots key) where
  map = fmapVirtualDomTree

-- Hyperscript

type Node :: (Row Type -> Row Type) -> (Type -> Row Type -> Row Type) -> (Row Type -> Row Type) -> Type
type Node mk_properties mk_outputs mk_attributes
  = forall bound_facts unbound_facts key _child_key attributes hooks substituted_slot downstream_slots message
  . Row.Union bound_facts unbound_facts (Facts mk_properties (mk_outputs message) attributes hooks)
 => Row.OptionalRecordCons bound_facts "attrs" (mk_attributes ()) attributes
 => Row.OptionalRecordCons bound_facts "hooks" (Hooks message) hooks
 => ExtractKeyType bound_facts key
 => { | bound_facts }
 -> Array (VirtualDomTree Slots.Default downstream_slots _child_key message)
 -> VirtualDomTree substituted_slot downstream_slots key message

foreign import node
  :: forall facts child_key key substituted_slot downstream_slots message
   . { ns       :: String
     , tagName  :: String
     , facts    :: { | facts }
     , children :: Array (VirtualDomTree Slots.Default downstream_slots child_key message)
     }
  -> VirtualDomTree substituted_slot downstream_slots key message

type Leaf :: (Row Type -> Row Type) -> (Type -> Row Type -> Row Type) -> (Row Type -> Row Type) -> Type
type Leaf mk_properties mk_outputs mk_attributes
  = forall bound_facts unbound_facts key attributes hooks substituted_slot downstream_slots message
  . Row.Union bound_facts unbound_facts (Facts mk_properties (mk_outputs message) attributes hooks)
 => Row.OptionalRecordCons bound_facts "attrs" (mk_attributes ()) attributes
 => Row.OptionalRecordCons bound_facts "hooks" (Hooks message) hooks
 => ExtractKeyType bound_facts key
 => { | bound_facts }
 -> VirtualDomTree substituted_slot downstream_slots key message

foreign import leaf
  :: forall facts key substituted_slot downstream_slots message
   . { ns      :: String
     , tagName :: String
     , facts   :: { | facts }
     }
  -> VirtualDomTree substituted_slot downstream_slots key message

foreign import text :: forall downstream_slots message. String -> VirtualDomTree Slots.Default downstream_slots Nothing message

foreign import keyed
  :: forall substituted_slot downstream_slots key message
   . key
  -> VirtualDomTree substituted_slot downstream_slots Nothing    message
  -> VirtualDomTree substituted_slot downstream_slots (Just key) message

class ExtractKeyType (row :: Row Type) (key :: Maybe Type) | row -> key

instance (RowToList row list, ExtractKeyType' list key) => ExtractKeyType row key

class ExtractKeyType' (row :: RowList Type) (key :: Maybe Type) | row -> key

instance ExtractKeyType' RowList.Nil Nothing

instance ExtractKeyType' (RowList.Cons "key" a _tail) (Just a)
else instance (ExtractKeyType' tail key) => ExtractKeyType' (RowList.Cons _name _t tail) key

data Slot
