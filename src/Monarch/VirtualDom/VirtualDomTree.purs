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
    , Node_
    , Leaf
    , class ExtractKeyType
    , class ExtractKeyType'
    , text
    , keyed
    , nodeNS
    , nodeNS_
    , nodeNS'
    , node
    , node_
    , node'
    ) where

import Prelude
import Undefined
import Type.Row as Row
import Type.RowList (kind RowList, class RowToList)
import Type.RowList as RowList
import Monarch.VirtualDom.Facts
import Monarch.VirtualDom.Facts.Hooks
import Monarch.VirtualDom.NS
import Monarch.VirtualDom.NS as NS
import Monarch.Type.Row as Row
import Monarch.Type.Maybe

foreign import data VirtualDomTree :: Maybe Type -> Row Type -> Type -> Type

foreign import fmapVirtualDomTree :: forall key slots a b. (a -> b) -> VirtualDomTree key slots a -> VirtualDomTree key slots b

instance Functor (VirtualDomTree key slots) where
    map = fmapVirtualDomTree

-- Hyperscript

type Node
    (mkProperties :: Row Type -> Row Type)
    (mkOutputs :: Type -> Row Type -> Row Type)
    (mkAttributes :: Row Type -> Row Type) =
    forall r _r keyType key key' attributes hooks slots message
     . Row.Union r _r (Facts mkProperties (mkOutputs message) attributes hooks keyType)
    => Row.OptionalRecordCons r "attrs" (mkAttributes ()) attributes
    => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
    => ExtractKeyType r key
    => { | r }
    -> Array (VirtualDomTree key' slots message)
    -> VirtualDomTree key slots message

type Node_ = forall key slots message. Array (VirtualDomTree key slots message) -> VirtualDomTree Nothing slots message

type Leaf
    (mkProperties :: Row Type -> Row Type)
    (mkOutputs :: Type -> Row Type -> Row Type)
    (mkAttributes :: Row Type -> Row Type) =
    forall r _r keyType key attributes hooks slots message
     . Row.Union r _r (Facts mkProperties (mkOutputs message) attributes hooks keyType)
    => Row.OptionalRecordCons r "attrs" (mkAttributes ()) attributes
    => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
    => ExtractKeyType r key
    => { | r }
    -> VirtualDomTree key slots message

foreign import text :: forall message. String -> VirtualDomTree Nothing () message

foreign import elementNS :: forall r key key' slots message. String -> String -> { | r } -> Array (VirtualDomTree key' slots message) -> VirtualDomTree key slots message
foreign import elementNS_ :: forall key' slots message. String -> String -> Array (VirtualDomTree key' slots message) -> VirtualDomTree Nothing slots message
foreign import elementNS__ :: forall slots message. String -> String -> VirtualDomTree Nothing slots message

foreign import keyed :: forall key slots message. key -> VirtualDomTree Nothing slots message -> VirtualDomTree (Just key) slots message

class ExtractKeyType (row :: Row Type) (key :: Maybe Type) | row -> key

instance (RowToList row list, ExtractKeyType' list key) => ExtractKeyType row key

class ExtractKeyType' (row :: RowList Type) (key :: Maybe Type) | row -> key

instance ExtractKeyType' RowList.Nil Nothing

instance ExtractKeyType' (RowList.Cons "key" a _tail) (Just a)
else instance (ExtractKeyType' tail key) => ExtractKeyType' (RowList.Cons _name _t tail) key

nodeNS
    :: forall r key key' slots message
     . ExtractKeyType r key
    => NS
    -> String
    -> { | r }
    -> Array (VirtualDomTree key' slots message)
    -> VirtualDomTree key slots message
nodeNS = elementNS <<< show

node
    :: forall r key key' slots message
     . ExtractKeyType r key
    => String
    -> { | r }
    -> Array (VirtualDomTree key' slots message)
    -> VirtualDomTree key slots message
node = elementNS undefined

nodeNS_
    :: forall key slots message
     . NS
    -> String
    -> Array (VirtualDomTree key slots message)
    -> VirtualDomTree Nothing slots message
nodeNS_ = elementNS_ <<< show

nodeNS'
    :: forall slots message
     . NS
    -> String
    -> VirtualDomTree Nothing slots message
nodeNS' = elementNS__ <<< show

node_
    :: forall key slots message
     . String
    -> Array (VirtualDomTree key slots message)
    -> VirtualDomTree Nothing slots message
node_ = elementNS_ undefined

node'
    :: forall slots message
     . String
    -> VirtualDomTree Nothing slots message
node' = elementNS__ undefined
