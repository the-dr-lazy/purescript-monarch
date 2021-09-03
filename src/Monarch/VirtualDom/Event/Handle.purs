{-|
Module     : Monarch.VirtualDom.Event.Handle
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.Event.Handle where

data EventHandle :: Boolean -> Boolean -> Type
data EventHandle bubbles composed

data CustomEventHandle :: Boolean -> Boolean -> Type -> Type
data CustomEventHandle bubbles composed detail

data UiEventHandle :: Boolean -> Boolean -> Type
data UiEventHandle bubbles composed

data MouseEventHandle :: Boolean -> Boolean -> Type
data MouseEventHandle bubbles composed

data WheelEventHandle :: Boolean -> Boolean -> Type
data WheelEventHandle bubbles composed
