{-|
Module     : Monarch.VirtualDom.Event.UiEvent
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.Event.UiEvent where

import Data.Maybe
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Monarch.VirtualDom.Event.Handle
import Prelude
import Web.HTML as Web

class UiEvent h where
  view :: h -> Maybe Web.Window

foreign import foreign_view :: forall a. a -> Nullable Web.Window

instance UiEvent (UiEventHandle bubbles composed) where
  view = Nullable.toMaybe <<< foreign_view

instance UiEvent (MouseEventHandle bubbles composed) where
  view = Nullable.toMaybe <<< foreign_view
