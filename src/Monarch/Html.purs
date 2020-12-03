{-|
Module     : Monarch.Html
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Html
  ( module Monarch.VirtualDom.VirtualDomTree.Prelude
  , Html , Html'
  , div, div_, div'
  , button, button_, button'
  )
where

import Prelude
import Effect                           ( Effect )
import Type.Row                         ( type (+) )
import Type.Row                                            as Row
import Web.HTML                         ( HTMLElement )
import Monarch.Type.Row                                    as Row
import Monarch.Html.Facts.Attributes
import Monarch.Html.Facts.Outputs
import Monarch.Html.Facts.Properties
import Monarch.VirtualDom.NS as NS
import Monarch.VirtualDom.VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree as VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree.Prelude
import Monarch.VirtualDom.Facts.Hooks

-- Data Type

type Html' = VirtualDomTree NS.HTML

type Html = Html' ()

-- Elements

type Node r slots message = VirtualDomTree.Node NS.HTML r slots message

type Node_ slots message = VirtualDomTree.Node_ NS.HTML slots message

type Leaf r slots message = VirtualDomTree.Leaf NS.HTML r slots message

type HtmlDivR attributes hooks message = R HtmlDivElementProperties (HtmlDivElementOutputs message) attributes hooks

div :: forall r _r attributes hooks slots message
     . Row.Union r _r (HtmlDivR attributes hooks message)
    => Row.OptionalRecordCons r "attrs" (HtmlDivElementAttributes ()) attributes
    => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
    => Node r slots message
div = node "div"

div_ :: forall slots message. Node_ slots message
div_ = node_ "div"

div' :: forall message. Html' () message
div' = node' "div"

type HtmlButtonR attributes hooks message = R HtmlButtonElementProperties (HtmlButtonElementOutputs message) attributes hooks

button :: forall r _r attributes hooks slots message
        . Row.Union r _r (HtmlButtonR attributes hooks message)
       => Row.OptionalRecordCons r "attrs" (HtmlButtonElementAttributes ()) attributes
       => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
       => Node r slots message
button = node "button"

button_ :: forall slots message. Node_ slots message
button_ = node_ "button"

button' :: forall message. Html message
button' = node' "button"
