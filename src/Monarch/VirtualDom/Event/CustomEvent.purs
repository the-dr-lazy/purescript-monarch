{-|
Module     : Monarch.VirtualDom.Event.CustomEvent
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.Event.CustomEvent where

import Monarch.VirtualDom.Event.Handle

class CustomEvent h where
  detail :: forall a. h a -> a

foreign import foreign_detail :: forall h a. h a -> a

instance CustomEvent (CustomEventHandle bubbles composed) where
  detail = foreign_detail
