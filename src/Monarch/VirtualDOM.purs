{-|
Module     : Monarch.VirtualDOM
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDOM where

import Prelude

import Effect                           ( Effect )
import Type.Row                         ( type (+) )
import Type.Row                                            as Row
import Web.HTML                         ( HTMLElement )
import Monarch.Type.Row                                    as Row
import Monarch.VirtualDOM.Attributes
import Monarch.VirtualDOM.Hooks
import Monarch.VirtualDOM.Outputs
import Monarch.VirtualDOM.Properties

-- Data Type

foreign import data VirtualNode' :: # Type -> Type -> Type

type VirtualNode = VirtualNode' ()

instance functorVirtualNode :: Functor (VirtualNode' slots) where
  map = virtualNodeMap

foreign import virtualNodeMap :: forall slots a b. (a -> b) -> VirtualNode' slots a -> VirtualNode' slots b

-- Virtual DOM API

foreign import mount :: forall slots message. (message -> Effect Unit) -> HTMLElement -> VirtualNode' slots message -> Effect Unit

foreign import patch :: forall slots message. (message -> Effect Unit) -> VirtualNode' slots message -> VirtualNode' slots message -> Effect Unit

foreign import unmount :: forall slots message. VirtualNode' slots message -> Effect Unit

-- Hyperscript

type Node (r       :: # Type)
          (slots   :: # Type)
          (message :: Type)
  = { | r } -> Array (VirtualNode' slots message) -> VirtualNode' slots message

type Node_ (slots   :: # Type)
           (message :: Type)
  = Array (VirtualNode' slots message) -> VirtualNode' slots message

type Leaf (r       :: # Type)
          (slots   :: # Type)
          (message :: Type)
  = { | r } -> VirtualNode' slots message

foreign import h :: forall r slots message. String -> Node r slots message

h_ :: forall slots message. String -> Node_ slots message
h_ selector = h selector {}

h' :: forall slots message. String -> VirtualNode' slots message 
h' selector = h_ selector mempty
              
foreign import text :: forall slots message. String -> VirtualNode' slots message 

-- Tags

type R (attributes :: # Type -> # Type)
       (outputs    :: # Type -> # Type)
       (props      :: # Type)
       (hooks      :: # Type)
  = attributes
  + outputs
  + ( props :: { | props }
    , hooks :: { | hooks }
    )

type HTMLDivR props hooks message = R HTMLDivElementAttributes (HTMLDivElementOutputs message) props hooks

div :: forall r r' props hooks slots message
     . Row.Union r r' (HTMLDivR props hooks message)
    => Row.OptionalRecordCons r "props" (HTMLDivElementProperties ()) props
    => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
    => { | r }
    -> Array (VirtualNode' slots message)
    -> VirtualNode' slots message
div = h "div"

div_ :: forall slots message. Array (VirtualNode' slots message) -> VirtualNode' slots message
div_ = h "div" {}

div' :: forall slots message. VirtualNode' slots message
div' = h "div" {} []

type HTMLButtonR props hooks message = R HTMLButtonElementAttributes (HTMLButtonElementOutputs message) props hooks

button :: forall r r' props hooks slots message
        . Row.Union r r' (HTMLButtonR props hooks message)
       => Row.OptionalRecordCons r "props" (HTMLButtonElementProperties ()) props
       => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
       => Node r slots message
button = h "button"

button_ :: forall slots message. Node_ slots message
button_ = h "button" {}

button' :: forall slots message. VirtualNode' slots message
button' = h "button" {} []
