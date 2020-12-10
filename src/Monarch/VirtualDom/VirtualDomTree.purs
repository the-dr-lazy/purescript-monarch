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
  , R
  , text
  , nodeNS, nodeNS_, nodeNS'
  , node, node_, node'
  )
where

import Prelude
import Undefined
import Type.Row                         ( type (+) )
import Monarch.VirtualDom.NS
import Monarch.VirtualDom.NS as NS

foreign import data VirtualDomTree :: # Type -> Type -> Type

-- Hyperscript

type Node (r       :: # Type)
          (slots   :: # Type)
          (message :: Type)
  = { | r } -> Array (VirtualDomTree slots message) -> VirtualDomTree slots message

type Node_ (slots   :: # Type)
           (message :: Type)
  = Array (VirtualDomTree slots message) -> VirtualDomTree slots message

type Leaf (r       :: # Type)
          (slots   :: # Type)
          (message :: Type)
  = { | r } -> VirtualDomTree slots message

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

nodeNS_ :: forall r slots message
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

type R (properties :: # Type -> # Type)
       (outputs    :: # Type -> # Type)
       (attributes :: # Type)
       (hooks      :: # Type)
  = properties
  + outputs
  + ( attributes :: { | attributes }
    , hooks      :: { | hooks }
    )
