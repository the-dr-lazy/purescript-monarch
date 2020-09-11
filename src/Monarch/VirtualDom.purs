module Monarch.VirtualDom where

import Prelude
import Effect (Effect)
import Type.Row                         ( type (+) )
import Web.HTML                         ( HTMLElement )
import Monarch.VirtualDom.NS (kind NS)
import Monarch.VirtualDom.NS as NS

-- Data Type

foreign import data VirtualNode :: NS -> # Type -> Type -> Type

type VirtualNode' (ns :: NS) = VirtualNode ns ()

instance functorVirtualNode :: Functor (VirtualNode ns slots) where
  map = virtualNodeMap

foreign import virtualNodeMap :: forall ns slots a b. (a -> b) -> VirtualNode ns slots a -> VirtualNode ns slots b

-- Virtual DOM API

foreign import mount :: forall slots message. (message -> Effect Unit) -> HTMLElement -> VirtualNode NS.HTML slots message -> Effect Unit

foreign import patch :: forall slots message. (message -> Effect Unit) -> VirtualNode NS.HTML slots message -> VirtualNode NS.HTML slots message -> Effect Unit

foreign import unmount :: forall slots message. VirtualNode NS.HTML slots message -> Effect Unit

-- Hyperscript

type Node (ns      :: NS)
          (r       :: # Type)
          (slots   :: # Type)
          (message :: Type)
  = { | r } -> Array (VirtualNode ns slots message) -> VirtualNode ns slots message

type Node_ (ns      :: NS)
           (slots   :: # Type)
           (message :: Type)
  = Array (VirtualNode ns slots message) -> VirtualNode ns slots message

type Leaf (ns      :: NS)
          (r       :: # Type)
          (slots   :: # Type)
          (message :: Type)
  = { | r } -> VirtualNode ns slots message

foreign import h :: forall r ns ns' slots message. String -> { | r } -> Array (VirtualNode ns slots message) -> VirtualNode ns' slots message

h_ :: forall ns ns' slots message. String -> Array (VirtualNode ns slots message) -> VirtualNode ns' slots message
h_ selector = h selector {}

h' :: forall ns slots message. String -> VirtualNode ns slots message 
h' selector = h_ selector mempty
              
foreign import text :: forall ns message. String -> VirtualNode' ns message 

type R (properties :: # Type -> # Type)
       (outputs    :: # Type -> # Type)
       (attributes :: # Type)
       (hooks      :: # Type)
  = properties
  + outputs
  + ( attrs :: { | attributes }
    , hooks :: { | hooks }
    )
