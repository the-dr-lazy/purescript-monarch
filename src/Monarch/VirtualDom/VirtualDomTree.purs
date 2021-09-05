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
  , node
  , leaf
  )
where

import Prelude
import Undefined
import Type.Row                                            as Row
import Type.RowList (kind RowList, class RowToList)
import Type.RowList as RowList
import Monarch.VirtualDom.Facts
import Monarch.VirtualDom.Facts.Hooks
import Monarch.Type.Row                                    as Row
import Monarch.Type.Maybe

foreign import data VirtualDomTree :: Maybe Type -> Row Type -> Type -> Type

foreign import fmapVirtualDomTree :: forall key slots a b. (a -> b) -> VirtualDomTree key slots a -> VirtualDomTree key slots b

instance Functor (VirtualDomTree key slots) where
  map = fmapVirtualDomTree

-- Hyperscript

type Node :: (Row Type -> Row Type) -> (Type -> Row Type -> Row Type) -> (Row Type -> Row Type) -> Type
type Node mk_properties mk_outputs mk_attributes
  = forall facts _facts _key key child_key attributes hooks slots message
  . Row.Union facts _facts (Facts mk_properties (mk_outputs message) attributes hooks _key)
 => Row.OptionalRecordCons facts "attrs" (mk_attributes ()) attributes
 => Row.OptionalRecordCons facts "hooks" (Hooks message) hooks
 => ExtractKeyType facts key
 => { | facts }
 -> Array (VirtualDomTree child_key slots message)
 -> VirtualDomTree key slots message

foreign import node
  :: forall facts child_key key slots message
   . { ns :: String
     , tagName :: String
     , facts :: { | facts }
     , children :: Array (VirtualDomTree child_key slots message)
     }
  -> VirtualDomTree key slots message

type Leaf :: (Row Type -> Row Type) -> (Type -> Row Type -> Row Type) -> (Row Type -> Row Type) -> Type
type Leaf mk_properties mk_outputs mk_attributes
  = forall facts _facts _key key attributes hooks slots message
  . Row.Union facts _facts (Facts mk_properties (mk_outputs message) attributes hooks _key)
 => Row.OptionalRecordCons facts "attrs" (mk_attributes ()) attributes
 => Row.OptionalRecordCons facts "hooks" (Hooks message) hooks
 => ExtractKeyType facts key
 => { | facts }
 -> VirtualDomTree key slots message

foreign import leaf
  :: forall facts child_key key slots message
   . { ns :: String
     , tagName :: String
     , facts :: { | facts }
     }
  -> VirtualDomTree key slots message

foreign import text :: forall message. String -> VirtualDomTree Nothing () message

foreign import keyed :: forall key slots message. key -> VirtualDomTree Nothing slots message -> VirtualDomTree (Just key) slots message

class ExtractKeyType (row :: Row Type) (key :: Maybe Type) | row -> key

instance (RowToList row list, ExtractKeyType' list key) => ExtractKeyType row key

class ExtractKeyType' (row :: RowList Type) (key :: Maybe Type) | row -> key

instance ExtractKeyType' RowList.Nil Nothing

instance ExtractKeyType' (RowList.Cons "key" a _tail) (Just a)
else instance (ExtractKeyType' tail key) => ExtractKeyType' (RowList.Cons _name _t tail) key
