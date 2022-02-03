{-|
Module     : Monarch.VirtualDom.Event
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.Event where

import Prelude
import Monarch.VirtualDom.Event.Handle

newtype EventName = UnsafeMkEventName String

class Event h where
  name :: h -> EventName

foreign import foreign_name :: forall a. a -> String

instance Event EventHandle where
  name = UnsafeMkEventName <<< foreign_name

instance Event UiEventHandle where
  name = UnsafeMkEventName <<< foreign_name

instance Event MouseEventHandle where
  name = UnsafeMkEventName <<< foreign_name

instance Event (CustomEventHandle detail) where
  name = UnsafeMkEventName <<< foreign_name
