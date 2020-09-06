{-|
Module     : Monarch.Html.Outputs
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Html.Outputs where

import Web.UIEvent.MouseEvent (MouseEvent)

type GlobalOutputs message r
  = ( onClick :: MouseEvent -> message
    | r
    )

type ElementOutputs message r = GlobalOutputs message r

type HTMLElementOutputs message r = ElementOutputs message r

type HTMLDivElementOutputs message r = HTMLElementOutputs message r

type HTMLButtonElementOutputs message r = HTMLElementOutputs message r
