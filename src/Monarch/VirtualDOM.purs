module Monarch.VirtualDOM where

import Prelude
import Effect
import Web.HTML         ( HTMLElement )
import Unsafe.Coerce    ( unsafeCoerce )

foreign import data VirtualNode :: Type -> Type

foreign import mount :: forall message. (message -> Effect Unit) -> HTMLElement -> VirtualNode message -> Effect Unit

foreign import patch :: forall message. (message -> Effect Unit) -> VirtualNode message -> VirtualNode message -> Effect Unit

foreign import h :: forall props message. String -> Record props -> Array (VirtualNode message) -> VirtualNode message 

h_ :: forall message. String -> Array (VirtualNode message) -> VirtualNode message 
h_ selector = h selector {}

h' :: forall message. String -> VirtualNode message 
h' selector = h_ selector mempty

text :: forall message. String -> VirtualNode message
text = unsafeCoerce 
