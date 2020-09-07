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
  ( module Monarch.VirtualDom.Text
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
import Monarch.Html.Attributes
import Monarch.Html.Outputs
import Monarch.Html.Properties
import Monarch.VirtualDom.NS as NS
import Monarch.VirtualDom
import Monarch.VirtualDom as VirtualDom
import Monarch.VirtualDom.Text
import Monarch.VirtualDom.Hooks

-- Data Type

type Html' = VirtualNode NS.HTML

type Html = Html' ()

-- Elements

type Node r slots message = VirtualDom.Node NS.HTML r slots message

type Node_ slots message = VirtualDom.Node_ NS.HTML slots message

type Leaf r slots message = VirtualDom.Leaf NS.HTML r slots message

type R (attributes :: # Type -> # Type)
       (outputs    :: # Type -> # Type)
       (props      :: # Type)
       (hooks      :: # Type)
  = attributes
  + outputs
  + ( props :: { | props }
    , hooks :: { | hooks }
    )

type HtmlDivR props hooks message = R HtmlDivElementAttributes (HtmlDivElementOutputs message) props hooks

div :: forall r r' props hooks slots message
     . Row.Union r r' (HtmlDivR props hooks message)
    => Row.OptionalRecordCons r "props" (HtmlDivElementProperties ()) props
    => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
    => Node r slots message
div = h "div"

div_ :: forall slots message. Node_ slots message
div_ = h "div" {}

div' :: forall message. Html' () message
div' = h "div" {} []

type HtmlButtonR props hooks message = R HtmlButtonElementAttributes (HtmlButtonElementOutputs message) props hooks

button :: forall r r' props hooks slots message
        . Row.Union r r' (HtmlButtonR props hooks message)
       => Row.OptionalRecordCons r "props" (HtmlButtonElementProperties ()) props
       => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
       => Node r slots message
button = h "button"

button_ :: forall slots message. Node_ slots message
button_ = h "button" {}

button' :: forall message. Html message
button' = h "button" {} []
