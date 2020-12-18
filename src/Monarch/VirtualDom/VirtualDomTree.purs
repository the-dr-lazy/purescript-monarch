{-|
Module     : Monarch.VirtualDom.VirtualDomTree
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.VirtualDomTree
  ( VirtualDomTree
  , Node, Node_
  , Leaf
<<<<<<< HEAD
=======
  , R
  , kind IsKeyed
  , class IsKeyedNode
  , class IsKeyedNode'
  , NotKeyed
  , Keyed
  , Key
>>>>>>> f16a28b... feat: add keyed node to VirtualDomTree
  , text
  , nodeNS, nodeNS_, nodeNS'
  , node, node_, node'
  )
where

import Prelude
import Undefined
<<<<<<< HEAD
import Type.Row                                            as Row
import Monarch.VirtualDom.Facts
import Monarch.VirtualDom.Facts.Hooks
=======
import Type.Row                         ( type (+) )
import Type.Row as Row
import Type.RowList (kind RowList, class RowToList)
import Type.RowList as RowList
>>>>>>> f16a28b... feat: add keyed node to VirtualDomTree
import Monarch.VirtualDom.NS
import Monarch.VirtualDom.NS as NS
import Monarch.Type.Row                                    as Row

foreign import unsafeGet :: forall r a. String -> Record r -> a

foreign import kind IsKeyed

foreign import data Keyed :: IsKeyed

foreign import data NotKeyed :: IsKeyed

foreign import data VirtualDomTree :: IsKeyed -> # Type -> Type -> Type

foreign import fmapVirtualDomTree :: forall isKeyed slots a b. (a -> b) -> VirtualDomTree isKeyed slots a -> VirtualDomTree isKeyed slots b

instance functorVirtualDomTree :: Functor (VirtualDomTree isKeyed slots) where
  map = fmapVirtualDomTree

-- Hyperscript

type Node (mkProperties :: # Type -> # Type)
          (mkOutputs    :: Type -> # Type -> # Type)
          (mkAttributes :: # Type -> # Type)
  = forall r _r attributes hooks slots message
  . Row.Union r _r (Facts mkProperties (mkOutputs message) attributes hooks)
 => Row.OptionalRecordCons r "attrs" (mkAttributes ()) attributes
 => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
 => { | r }
 -> Array (VirtualDomTree slots message)
 -> VirtualDomTree slots message

type Node_
  = forall slots message. Array (VirtualDomTree slots message) -> VirtualDomTree slots message

type Leaf (mkProperties :: # Type -> # Type)
          (mkOutputs    :: Type -> # Type -> # Type)
          (mkAttributes :: # Type -> # Type)
  = forall r _r attributes hooks slots message
  . Row.Union r _r (Facts mkProperties (mkOutputs message) attributes hooks)
 => Row.OptionalRecordCons r "attrs" (mkAttributes ()) attributes
 => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
 => { | r }
 -> VirtualDomTree slots message

foreign import text :: forall message. String -> VirtualDomTree NotKeyed () message

foreign import elementNS   :: forall r isKeyed _isKeyed slots message.
                                 String -> String -> String -> { | r }
                              -> Array (VirtualDomTree _isKeyed slots message)
                              -> VirtualDomTree isKeyed slots message
foreign import elementNS_  :: forall isKeyed slots message. String -> String -> Array (VirtualDomTree isKeyed slots message) -> VirtualDomTree NotKeyed slots message
foreign import elementNS__ :: forall slots message.         String -> String -> VirtualDomTree NotKeyed slots message

class IsKeyedNode (row :: # Type) (isKeyed :: IsKeyed) | row -> isKeyed

instance rowListIsKeyedNode :: (RowToList row list, IsKeyedNode' list isKeyed) => IsKeyedNode row isKeyed

class IsKeyedNode' (row :: RowList) (isKeyed :: IsKeyed) | row -> isKeyed

instance nilIsKeyedNode :: IsKeyedNode' RowList.Nil NotKeyed

instance consIsKeyedNode :: IsKeyedNode' (RowList.Cons "key" String _tail) Keyed
else instance fallbackCdonsIsKeyedNode :: (IsKeyedNode' tail isKeyed) => IsKeyedNode' (RowList.Cons _name _t tail) isKeyed

-- node' = node__
nodeNS :: forall r isKeyed _isKeyed slots message
      . (IsKeyedNode r isKeyed)
      => NS
      -> String
      -> { | r }
      -> Array (VirtualDomTree _isKeyed slots message)
      -> VirtualDomTree isKeyed slots message
nodeNS ns tagName facts  = elementNS (show ns) tagName key facts
  where
    key = unsafeGet "key" facts

node :: forall r isKeyed _isKeyed slots message
      . (IsKeyedNode r isKeyed)
    => String
    -> { | r }
    -> Array (VirtualDomTree _isKeyed slots message)
    -> VirtualDomTree isKeyed slots message
node tagName facts = elementNS undefined tagName key facts
  where
    key = unsafeGet "key" facts

nodeNS_ :: forall isKeyed slots message
        . NS
      -> String
      -> Array (VirtualDomTree isKeyed slots message)
      -> VirtualDomTree NotKeyed slots message
nodeNS_ = elementNS_ <<< show

nodeNS' :: forall slots message
        . NS
      -> String
      -> VirtualDomTree NotKeyed slots message
nodeNS' = elementNS__ <<< show

node_ :: forall isKeyed slots message
      . String
    -> Array (VirtualDomTree isKeyed slots message)
    -> VirtualDomTree NotKeyed slots message
node_ = elementNS_ undefined

node' :: forall slots message
      . String
    -> VirtualDomTree NotKeyed slots message
node' = elementNS__ undefined
<<<<<<< HEAD
=======

type R (properties :: # Type -> # Type)
       (outputs    :: # Type -> # Type)
       (attributes :: # Type)
       (hooks      :: # Type)
  = properties
  + outputs
  + Key
  + ( attributes :: { | attributes }
    , hooks      :: { | hooks }
    )

type Key (r :: # Type)
  = ( key :: String
    | r
    )

>>>>>>> f16a28b... feat: add keyed node to VirtualDomTree
