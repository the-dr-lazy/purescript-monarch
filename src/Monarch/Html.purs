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

type HTMLDivR props hooks message = R HTMLDivElementAttributes (HTMLDivElementOutputs message) props hooks

div :: forall r r' props hooks slots message
     . Row.Union r r' (HTMLDivR props hooks message)
    => Row.OptionalRecordCons r "props" (HTMLDivElementProperties ()) props
    => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
    => Node r slots message
div = h "div"

div_ :: forall slots message. Node_ slots message
div_ = h "div" {}

div' :: forall message. Html' () message
div' = h "div" {} []

type HTMLButtonR props hooks message = R HTMLButtonElementAttributes (HTMLButtonElementOutputs message) props hooks

button :: forall r r' props hooks slots message
        . Row.Union r r' (HTMLButtonR props hooks message)
       => Row.OptionalRecordCons r "props" (HTMLButtonElementProperties ()) props
       => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
       => Node r slots message
button = h "button"

button_ :: forall slots message. Node_ slots message
button_ = h "button" {}

button' :: forall message. Html message
button' = h "button" {} []
