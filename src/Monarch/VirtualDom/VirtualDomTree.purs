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
  , class Node
  , class Leaf
  , class ExtractKeyType
  , class ExtractKeyType'
  , text
  , keyed
  , node
  , leaf
  )
where

import Data.Symbol
import Monarch.Type.Maybe
import Monarch.Type.Row as Row
import Monarch.VirtualDom.Facts
import Monarch.VirtualDom.NS (NS, reflectNS, class IsNS)
import Monarch.VirtualDom.NS as NS
import Prelude
import Type.Equality
import Type.Proxy
import Type.Row as Row
import Type.RowList (RowList, class RowToList)
import Type.RowList as RowList
import Undefined
import Unsafe.Coerce

foreign import data VirtualDomTree :: Maybe Type -> Row Type -> Type -> Type

foreign import fmapVirtualDomTree :: forall key slots a b. (a -> b) -> VirtualDomTree key slots a -> VirtualDomTree key slots b

instance Functor (VirtualDomTree key slots) where
  map = fmapVirtualDomTree

-- Hyperscript

foreign import text :: forall message. String -> VirtualDomTree Nothing () message

foreign import mkElementNS
  :: forall r key child_key slots message
   . { ns :: String
     , tagName :: String
     , facts :: { | r }
     , children :: Array (VirtualDomTree child_key slots message)
     }
  -> VirtualDomTree key slots message

class Node :: NS -> Symbol ->  Type -> Constraint
class Node ns tag_name return where
  node :: { ns :: Proxy ns, tagName :: Proxy tag_name } -> return

instance
  ( TypeEquals child (VirtualDomTree _child_key slots message)
  , TypeEquals return (VirtualDomTree key slots message)
  , IsNS ns
  , IsSymbol tag_name
  , Facts ns tag_name message facts
  , ExtractKeyType facts key
  )
  => Node ns tag_name ({ | facts } -> Array child -> return) where
  node proxies facts children = unsafeCoerce
    (mkElementNS { ns: reflectNS proxies.ns
                 , tagName: reflectSymbol proxies.tagName
                , facts: facts
                , children: unsafeCoerce children
                })
else instance
  ( TypeEquals child (VirtualDomTree _child_key slots message)
  , TypeEquals return (VirtualDomTree Nothing slots message)
  , IsNS ns
  , IsSymbol tag_name
  )
  => Node ns tag_name (Array child -> return) where
  node proxies children = unsafeCoerce
    (mkElementNS { ns: reflectNS proxies.ns
                 , tagName: reflectSymbol proxies.tagName
                 , facts: undefined
                 , children: unsafeCoerce children
                 })
else instance (Leaf ns tag_name return) => Node ns tag_name return where
  node = leaf

class Leaf :: NS -> Symbol -> Type -> Constraint
class Leaf ns tag_name r where
  leaf :: { ns :: Proxy ns, tagName :: Proxy tag_name } -> r

instance
  ( TypeEquals return (VirtualDomTree key slots message)
  , IsNS ns
  , IsSymbol tag_name
  , Facts ns tag_name message facts
  , ExtractKeyType facts key
  )
  => Leaf ns tag_name ({ | facts } -> return) where
  leaf proxies facts = unsafeCoerce
    (mkElementNS { ns: reflectNS proxies.ns
                 , tagName: reflectSymbol proxies.tagName
                 , facts: facts
                 , children: undefined
                 })
else instance
  ( TypeEquals return (VirtualDomTree Nothing slots message)
  , IsNS ns
  , IsSymbol tag_name
  )
  => Leaf ns tag_name return where
  leaf proxies = unsafeCoerce
    (mkElementNS { ns: reflectNS proxies.ns
                 , tagName: reflectSymbol proxies.tagName
                 , facts: undefined
                 , children: undefined
                 })

foreign import keyed :: forall key slots message. key -> VirtualDomTree Nothing slots message -> VirtualDomTree (Just key) slots message

class ExtractKeyType (row :: Row Type) (key :: Maybe Type) | row -> key

instance (RowToList row list, ExtractKeyType' list key) => ExtractKeyType row key

class ExtractKeyType' (row :: RowList Type) (key :: Maybe Type) | row -> key

instance ExtractKeyType' RowList.Nil Nothing

instance ExtractKeyType' (RowList.Cons "key" a _tail) (Just a)
else instance (ExtractKeyType' tail key) => ExtractKeyType' (RowList.Cons _name _t tail) key
