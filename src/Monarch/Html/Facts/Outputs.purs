{-|
Module     : Monarch.Html.Facts.Outputs
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Html.Facts.Outputs where

import Monarch.VirtualDom.Facts.Outputs

type HtmlElementOutputs message r = ElementOutputs message r

type HtmlDivElementOutputs message r = HtmlElementOutputs message r

type HtmlButtonElementOutputs message r = HtmlElementOutputs message r
