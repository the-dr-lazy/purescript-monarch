{-|
Module     : Counter.Elements.Counter
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Counter.Elements.Counter where

import Data.Maybe
import Data.Nullable
import Effect
import Monarch.Element
import Monarch.VirtualDom.VirtualDomTree
import Prelude
import Run
import Type.Proxy
import Undefined

import Data.Variant (Variant)
import Monarch.Effect as Monarch.Effect
import Monarch.Html as Html
import Monarch.VirtualDom.Event.Handle (CustomEventHandle)
import Type.Row (type (+))
import Monarch as Monarch
import Type.Prelude
import Monarch.VirtualDom.Event.CustomEvent as CustomEvent

data Size = Size

instance AsProperty Size (Maybe String) where
  fromProperty = undefined
  toProperty = undefined

type Input = ( value :: Maybe Int
             )

type Options
  = ( value :: Reflect
    )

data Model = Controlled Int
           | Uncontrolled Int

mkInitialModel :: { | Input } -> Effect Model
mkInitialModel { value } = pure (fromMaybe (Uncontrolled 0) (Controlled <$> value))

data Message
  = UserClickedIncrement
  | UserClickedDecrement
  | MonarchSentNewInput { | Input }

update :: Message -> Model -> Model
update message model = case message, model of
  UserClickedIncrement, Uncontrolled x -> Uncontrolled (x + 1)
  UserClickedDecrement, Uncontrolled x -> Uncontrolled (x - 1)
  UserClickedIncrement, Controlled _ -> model
  UserClickedDecrement, Controlled _ -> model
  MonarchSentNewInput { value }, _ ->
    fromMaybe (Uncontrolled 0) (Controlled <$> value)

type Slots
  = ( title    :: Maybe Slot
    , decrease :: Maybe Slot
    , increase :: Maybe Slot
    )

f :: Model -> Int
f = case _ of
  Controlled x -> x
  Uncontrolled x -> x

view :: Model -> Html.Host Slots Message
view model =
  Html.div {}
    [ Html.slot { name: Proxy :: Proxy "title" } [ Html.text "Counter: " ]
    , Html.button { onClick: pure UserClickedDecrement }
        [ Html.slot { name: Proxy :: Proxy "decrease" } [ Html.text "-" ] ]
    , Html.text $ show (f model)
    , Html.button { onClick: pure UserClickedIncrement }
        [ Html.slot { name: Proxy :: Proxy "increase" } [ Html.text "+" ] ]
    ]

type Output = Variant (change :: CustomEventHandle Unit)

command
  :: Message
  -> Model
  -> Run (Monarch.Effect.Basic Message Output ()) Unit
command message _ = case message of
  UserClickedIncrement -> Monarch.raise onChangeEvent
  _                    -> pure unit

onChangeEvent :: forall r. Variant (change :: CustomEventHandle Unit | r)
onChangeEvent = CustomEvent.mk { name: Proxy :: Proxy "change"
                               , detail: unit
                               }

node = mkElement { tagName: "monarch-counter"
                 , mkInitialModel
                 , command
                 , interpreter: identity
                 , update
                 , view
                 , onInitialize: Nothing
                 , onFinalize: Nothing
                 , onInputChange: Just MonarchSentNewInput
                 , options: Proxy :: Proxy Options
                 }
