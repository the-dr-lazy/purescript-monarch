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
  , Node, Node_
  , Leaf
  , text
  , nodeNS, nodeNS_, nodeNS'
  , node, node_, node'
  )
where

import Prelude
import Undefined
import Type.Row                                            as Row
import Monarch.VirtualDom.Facts
import Monarch.VirtualDom.Facts.Hooks
import Monarch.VirtualDom.NS
import Monarch.VirtualDom.NS as NS
import Monarch.Type.Row                                    as Row

foreign import data VirtualDomTree :: Row Type -> Type -> Type

foreign import fmapVirtualDomTree :: forall slots a b. (a -> b) -> VirtualDomTree slots a -> VirtualDomTree slots b

instance functorVirtualDomTree :: Functor (VirtualDomTree slots) where
  map = fmapVirtualDomTree

-- Hyperscript

type Node (mkProperties :: Row Type -> Row Type)
          (mkOutputs    :: Type -> Row Type -> Row Type)
          (mkAttributes :: Row Type -> Row Type)
  = forall r _r attributes hooks slots message
  . Row.Union r _r (Facts mkProperties (mkOutputs message) attributes hooks)
 => Row.OptionalRecordCons r "attrs" (mkAttributes ()) attributes
 => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
 => { | r }
 -> Array (VirtualDomTree slots message)
 -> VirtualDomTree slots message

type Node_
  = forall slots message. Array (VirtualDomTree slots message) -> VirtualDomTree slots message

type Leaf (mkProperties :: Row Type -> Row Type)
          (mkOutputs    :: Type -> Row Type -> Row Type)
          (mkAttributes :: Row Type -> Row Type)
  = forall r _r attributes hooks slots message
  . Row.Union r _r (Facts mkProperties (mkOutputs message) attributes hooks)
 => Row.OptionalRecordCons r "attrs" (mkAttributes ()) attributes
 => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
 => { | r }
 -> VirtualDomTree slots message

foreign import text :: forall message. String -> VirtualDomTree () message

foreign import elementNS   :: forall r slots message. String -> String -> { | r } -> Array (VirtualDomTree slots message) -> VirtualDomTree slots message
foreign import elementNS_  :: forall   slots message. String -> String            -> Array (VirtualDomTree slots message) -> VirtualDomTree slots message
foreign import elementNS__ :: forall   slots message. String -> String                                                    -> VirtualDomTree slots message

-- node' = node__
nodeNS :: forall r slots message
        . NS
       -> String
       -> { | r }
       -> Array (VirtualDomTree slots message)
       -> VirtualDomTree slots message
nodeNS = elementNS <<< show

nodeNS_ :: forall slots message
        . NS
       -> String
       -> Array (VirtualDomTree slots message)
       -> VirtualDomTree slots message
nodeNS_ = elementNS_ <<< show

nodeNS' :: forall slots message
        . NS
       -> String
       -> VirtualDomTree slots message
nodeNS' = elementNS__ <<< show

node :: forall r slots message
      . String
     -> { | r }
     -> Array (VirtualDomTree slots message)
     -> VirtualDomTree slots message
node = elementNS undefined

node_ :: forall slots message
      . String
     -> Array (VirtualDomTree slots message)
     -> VirtualDomTree slots message
node_ = elementNS_ undefined


node' :: forall slots message
      . String
     -> VirtualDomTree slots message
node' = elementNS__ undefined
