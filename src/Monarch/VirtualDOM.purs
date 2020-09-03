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
import Unsafe.Coerce                    ( unsafeCoerce )

foreign import data VirtualNode' :: # Type -> Type -> Type

type VirtualNode = VirtualNode' ()

foreign import mount :: forall slots message. (message -> Effect Unit) -> HTMLElement -> VirtualNode' slots message -> Effect Unit

foreign import patch :: forall slots message. (message -> Effect Unit) -> VirtualNode' slots message -> VirtualNode' slots message -> Effect Unit

foreign import unmount :: forall slots message. VirtualNode' slots message -> Effect Unit

foreign import virtualNodeMap :: forall slots a b. (a -> b) -> VirtualNode' slots a -> VirtualNode' slots b

instance functorVirtualNode :: Functor (VirtualNode' slots) where
  map = virtualNodeMap

foreign import h :: forall r slots message. String -> { | r } -> Array (VirtualNode' slots message) -> VirtualNode' slots message 

h_ :: forall slots message. String -> Array (VirtualNode' slots message) -> VirtualNode' slots message 
h_ selector = h selector {}

h' :: forall slots message. String -> VirtualNode' slots message 
h' selector = h_ selector mempty

text :: forall slots message. String -> VirtualNode' slots message
text = unsafeCoerce 
