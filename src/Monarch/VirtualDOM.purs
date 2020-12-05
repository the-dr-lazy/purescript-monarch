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
import Effect
import Web.HTML         ( HTMLElement )
import Unsafe.Coerce    ( unsafeCoerce )

foreign import data VirtualNode :: Type -> Type

foreign import mount :: forall message
                      . (message -> Effect Unit)
                      -> HTMLElement
                      -> VirtualNode message
                      -> Effect Unit

foreign import patch :: forall message
                      . (message -> Effect Unit)
                      -> VirtualNode message
                      -> VirtualNode message
                      -> Effect Unit

foreign import unmount :: forall message
                        . VirtualNode message
                       -> Effect Unit

foreign import virtualNodeMap :: forall a b. (a -> b) -> VirtualNode a -> VirtualNode b

instance functorVirtualNode :: Functor VirtualNode where
  map = virtualNodeMap

foreign import h :: forall props message. String -> Record props -> Array (VirtualNode message) -> VirtualNode message

h_ :: forall message. String -> Array (VirtualNode message) -> VirtualNode message
h_ selector = h selector {}

h' :: forall message. String -> VirtualNode message
h' selector = h_ selector mempty

text :: forall message. String -> VirtualNode message
text = unsafeCoerce
