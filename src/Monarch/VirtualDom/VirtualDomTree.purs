{-|
Module     : Monarch.VirtualDom.VirtualDomTree
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.VirtualDomTree
  ( VirtualDomTree, VirtualDomTree'
  , Node, Node_
  , Leaf
  , R
  , text
  , node, node_, node'
  )
where

import Type.Row                         ( type (+) )
import Monarch.VirtualDom.NS (kind NS)
import Monarch.VirtualDom.NS as NS

foreign import data VirtualDomTree :: NS -> # Type -> Type -> Type

type VirtualDomTree' (ns :: NS) = VirtualDomTree ns ()

-- Hyperscript

type Node (ns      :: NS)
          (r       :: # Type)
          (slots   :: # Type)
          (message :: Type)
  = { | r } -> Array (VirtualDomTree ns slots message) -> VirtualDomTree ns slots message

type Node_ (ns      :: NS)
           (slots   :: # Type)
           (message :: Type)
  = Array (VirtualDomTree ns slots message) -> VirtualDomTree ns slots message

type Leaf (ns      :: NS)
          (r       :: # Type)
          (slots   :: # Type)
          (message :: Type)
  = { | r } -> VirtualDomTree ns slots message

foreign import text :: forall ns message. String -> VirtualDomTree' ns message

foreign import node   :: forall r ns ns' slots message. String -> { | r } -> Array (VirtualDomTree ns slots message) -> VirtualDomTree ns' slots message
foreign import node_  :: forall ns   ns' slots message. String ->            Array (VirtualDomTree ns slots message) -> VirtualDomTree ns' slots message
foreign import node__ :: forall      ns' slots message. String ->                                                       VirtualDomTree ns' slots message

node' = node__
              

type R (properties :: # Type -> # Type)
       (outputs    :: # Type -> # Type)
       (attributes :: # Type)
       (hooks      :: # Type)
  = properties
  + outputs
  + ( attributes :: { | attributes }
    , hooks      :: { | hooks }
    )
