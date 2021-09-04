{-|
Module     : Monarch.Html.Facts.Attributes
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Html.Facts.Attributes where

import Type.Row (type (+))
import Monarch.VirtualDom.Facts.Attributes

type HtmlDivElementAttributes r = GlobalAttributes r

type HtmlButtonElementAttributes r
    = GlobalAttributes
    +
        ( autofocus :: Boolean -- | Automatically focus the form control when the page is loaded
        , disabled :: Boolean -- | Whether the form control is disabled
        | r
        )
