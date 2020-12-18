{-|
Module     : Monarch.Html
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Html
  ( module Monarch.VirtualDom.VirtualDomTree.Prelude
  , Html
  , div, div_, div'
  , button, button_, button'
  )
where

import Monarch.Html.Facts.Attributes
import Monarch.Html.Facts.Outputs
import Monarch.Html.Facts.Properties
import Monarch.VirtualDom.VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree as VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree.Prelude

-- Data Type

type Html = VirtualDomTree NotKeyed ()

-- Elements

div :: Node HtmlDivElementProperties HtmlDivElementOutputs HtmlDivElementAttributes
div = node "div"

div_ :: Node_
div_ = node_ "div"

div' :: forall message. Html message
div' = node' "div"

button :: Node HtmlButtonElementProperties HtmlButtonElementOutputs HtmlButtonElementAttributes
button = node "button"

button_ :: Node_
button_ = node_ "button"

button' :: forall message. Html message
button' = node' "button"
