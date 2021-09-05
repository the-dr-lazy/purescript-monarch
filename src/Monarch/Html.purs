{-|
Module     : Monarch.Html
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
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
  )
where

import Monarch.Html.Facts.Attributes
import Monarch.Html.Facts.Outputs
import Monarch.Html.Facts.Properties
import Monarch.Type.Maybe
import Monarch.VirtualDom.Facts
import Monarch.VirtualDom.Facts.Hooks
import Monarch.VirtualDom.VirtualDomTree (VirtualDomTree)
import Monarch.VirtualDom.VirtualDomTree as VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree.Prelude
import Monarch.VirtualDom.Facts.Hooks
import Monarch.Type.Maybe


type Root downstream_outputs message = forall substituted_slot. VirtualDomTree substituted_slot () downstream_outputs Nothing message

foreign import div :: VirtualDomTree.Node HtmlDivElementProperties HtmlDivElementOutputs HtmlDivElementAttributes
foreign import button :: VirtualDomTree.Node HtmlButtonElementProperties HtmlButtonElementOutputs HtmlButtonElementAttributes
