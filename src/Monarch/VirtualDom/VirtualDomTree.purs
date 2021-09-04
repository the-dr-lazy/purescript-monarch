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
  :: forall r key key' slots message
   . { ns :: String
     , tagName :: String
     , facts :: { | r }
     , children :: Array (VirtualDomTree key' slots message)
     }
  -> VirtualDomTree key slots message

class Node :: NS -> Symbol ->  Type -> Constraint
class Node ns tagName r where
  node :: { ns :: Proxy ns, tagName :: Proxy tagName } -> r

instance
  ( TypeEquals child (VirtualDomTree key' slots message)
  , TypeEquals v (VirtualDomTree key slots message)
  , IsNS ns
  , IsSymbol tagName
  , Facts ns tagName message facts
  , ExtractKeyType facts key
  )
  => Node ns tagName ({ | facts } -> Array child -> v) where
  node proxies facts children = unsafeCoerce
    (mkElementNS { ns: reflectNS proxies.ns
                , tagName: reflectSymbol proxies.tagName
                , facts: facts
                , children: unsafeCoerce children
                })
else instance
  ( TypeEquals child (VirtualDomTree key' slots message)
  , TypeEquals v (VirtualDomTree Nothing slots message)
  , IsNS ns
  , IsSymbol tagName
  )
  => Node ns tagName (Array child -> v) where
  node proxies children = unsafeCoerce
    (mkElementNS { ns: reflectNS proxies.ns
                , tagName: reflectSymbol proxies.tagName
                , facts: undefined
                , children: unsafeCoerce children
                })
else instance (Leaf ns tagName return) => Node ns tagName return where
  node = leaf

class Leaf :: NS -> Symbol -> Type -> Constraint
class Leaf ns tagName r where
  leaf :: { ns :: Proxy ns, tagName :: Proxy tagName } -> r

instance
  ( TypeEquals v (VirtualDomTree key slots message)
  , IsNS ns
  , IsSymbol tagName
  , Facts ns tagName message facts
  , ExtractKeyType facts key
  )
  => Leaf ns tagName ({ | facts } -> v) where
  leaf proxies facts = unsafeCoerce
    (mkElementNS { ns: reflectNS proxies.ns
                , tagName: reflectSymbol proxies.tagName
                , facts: facts
                , children: undefined
                })
else instance
  ( TypeEquals v (VirtualDomTree Nothing slots message)
  , IsNS ns
  , IsSymbol tagName
  )
  => Leaf ns tagName v where
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
