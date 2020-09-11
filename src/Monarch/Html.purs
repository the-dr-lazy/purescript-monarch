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

type HtmlDivR attributes hooks message = R HtmlDivElementProperties (HtmlDivElementOutputs message) attributes hooks

div :: forall r _r attributes hooks slots message
     . Row.Union r _r (HtmlDivR attributes hooks message)
    => Row.OptionalRecordCons r "attrs" (HtmlDivElementAttributes ()) attributes
    => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
    => Node r slots message
div = h "div"

div_ :: forall slots message. Node_ slots message
div_ = h "div" {}

div' :: forall message. Html' () message
div' = h "div" {} []

type HtmlButtonR attributes hooks message = R HtmlButtonElementProperties (HtmlButtonElementOutputs message) attributes hooks

button :: forall r _r attributes hooks slots message
        . Row.Union r _r (HtmlButtonR attributes hooks message)
       => Row.OptionalRecordCons r "attrs" (HtmlButtonElementAttributes ()) attributes
       => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
       => Node r slots message
button = h "button"

button_ :: forall slots message. Node_ slots message
button_ = h "button" {}

button' :: forall message. Html message
button' = h "button" {} []
