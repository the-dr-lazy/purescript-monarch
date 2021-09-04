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
  , HTML
  , Html
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
import Monarch.VirtualDom.VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree as VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree.Prelude
import Monarch.VirtualDom.NS
import Undefined
import Type.Proxy

foreign import data HTML :: NS

instance IsNS HTML where
  reflectNS _ = undefined

type Html = VirtualDomTree Nothing ()

-- Elements

instance
  (MkFacts (HtmlDivElementProperties ())
           (HtmlDivElementOutputs message ())
           (HtmlDivElementAttributes ())
           message
           facts
  )
  => Facts HTML "div" message facts

div =
  node { ns: Proxy :: Proxy HTML
       , tagName: Proxy :: Proxy "div"
       }

instance
  (MkFacts (HtmlButtonElementProperties ())
           (HtmlButtonElementOutputs message ())
           (HtmlButtonElementAttributes ())
           message
           facts
  )
  => Facts HTML "button" message facts

button =
  node { ns: Proxy :: Proxy HTML
       , tagName: Proxy :: Proxy "button"
       }
