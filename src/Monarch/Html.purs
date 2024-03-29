{-|
Module     : Monarch.Html
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Html
    ( module Monarch.VirtualDom.VirtualDomTree.Prelude
    , Root
    , div
    , button
    ) where

import Monarch.Html.Facts.Attributes
import Monarch.Html.Facts.Outputs
import Monarch.Html.Facts.Properties
import Monarch.VirtualDom.VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree as VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree.Prelude
import Monarch.VirtualDom.Facts.Hooks
import Monarch.Type.Maybe
import Undefined

type Root = VirtualDomTree Nothing ()

div :: VirtualDomTree.Node HtmlDivElementProperties HtmlDivElementOutputs HtmlDivElementAttributes
div facts = VirtualDomTree.node { ns: undefined, tagName: "div", facts }

button :: VirtualDomTree.Node HtmlButtonElementProperties HtmlButtonElementOutputs HtmlButtonElementAttributes
button facts = VirtualDomTree.node { ns: undefined, tagName: "button", facts }
