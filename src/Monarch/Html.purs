module Monarch.Html where

import Prelude

import Effect                           ( Effect )
import Type.Row                         ( type (+) )
import Type.Row                                            as Row
import Web.HTML                         ( HTMLElement )
import Monarch.Type.Row                                    as Row
import Monarch.Html.Attributes
import Monarch.Html.Hooks
import Monarch.Html.Outputs
import Monarch.Html.Properties

-- Data Type

foreign import data Html' :: # Type -> Type -> Type

type Html = Html' ()

instance functorVirtualNode :: Functor (Html' slots) where
  map = virtualNodeMap

foreign import virtualNodeMap :: forall slots a b. (a -> b) -> Html' slots a -> Html' slots b

-- Virtual DOM API

foreign import mount :: forall slots message. (message -> Effect Unit) -> HTMLElement -> Html' slots message -> Effect Unit

foreign import patch :: forall slots message. (message -> Effect Unit) -> Html' slots message -> Html' slots message -> Effect Unit

foreign import unmount :: forall slots message. Html' slots message -> Effect Unit

-- Hyperscript

type Node (r       :: # Type)
          (slots   :: # Type)
          (message :: Type)
  = { | r } -> Array (Html' slots message) -> Html' slots message

type Node_ (slots   :: # Type)
           (message :: Type)
  = Array (Html' slots message) -> Html' slots message

type Leaf (r       :: # Type)
          (slots   :: # Type)
          (message :: Type)
  = { | r } -> Html' slots message

foreign import h :: forall r slots message. String -> Node r slots message

h_ :: forall slots message. String -> Node_ slots message
h_ selector = h selector {}

h' :: forall slots message. String -> Html' slots message 
h' selector = h_ selector mempty
              
foreign import text :: forall slots message. String -> Html' slots message 

-- Tags

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
    => { | r }
    -> Array (Html' slots message)
    -> Html' slots message
div = h "div"

div_ :: forall slots message. Array (Html' slots message) -> Html' slots message
div_ = h "div" {}

div' :: forall slots message. Html' slots message
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

button' :: forall slots message. Html' slots message
button' = h "button" {} []
