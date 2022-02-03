{-|
Module     : Counter.Main
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Counter.Main (main) where

import Prelude
import Run                   ( Run )
import Effect                ( Effect )
import Effect.Aff            ( launchAff_ )
import Web.HTML              ( HTMLElement )
import Monarch.Effect as Monarch.Effect
import Monarch                                   as Monarch
import Monarch.Html as Html
import Counter.Effect.Api                               as Effect.Api
import Data.Maybe
import Monarch.VirtualDom.Facts.Attributes
import Type.Row (type (+))
import Counter.Elements.Counter

type Model = Int

data Message
  = MonarchSentInitialize
  | UserClickedIncreaseButton
  | UserClickedDecreaseButton

type Output = Void

update :: Message -> Model -> Model
update = case _ of
  UserClickedIncreaseButton -> (_ + 1)
  UserClickedDecreaseButton -> (_ - 1)
  _ -> identity

view :: Model -> Html.Root Message
view model =
  Html.div {}
    [ Html.button { onClick: const UserClickedDecreaseButton } [ Html.text "-" ]
    , Html.text $ show model
    , Html.button { onClick: const UserClickedIncreaseButton } [ Html.text "+" ]
    , node
        { value: Just model
        , onChange: const UserClickedIncreaseButton
        }
        { title: Html.div {} [ Html.text "HI! I'm Monarch element" ]
        , increase: Html.div {} [Html.text "INCREMENT"]
        , decrease: Html.div {} [Html.text "DECREMENT"]
        }
    ]

command
  :: Message
  -> Model
  -> Run (Monarch.Effect.Basic Message Output + Effect.Api.Counter ()) Unit
command message _ = case message of
  MonarchSentInitialize -> do
    Monarch.dispatch UserClickedIncreaseButton
    pure unit
  UserClickedIncreaseButton -> Effect.Api.increase
  UserClickedDecreaseButton -> Effect.Api.decrease

interpreter
  :: Run (Monarch.Effect.Basic Message Output + Effect.Api.Counter ())
  ~> Run (Monarch.Effect.Basic Message Output ())
interpreter = Effect.Api.run

main :: HTMLElement -> Effect Unit
main container = do
  Monarch.mkApplication { initialModel: 0
                        , update
                        , view
                        , command
                        , interpreter
                        , container
                        , onInitialize: Just MonarchSentInitialize
                        , onOutput: \_ -> pure unit
                        }
