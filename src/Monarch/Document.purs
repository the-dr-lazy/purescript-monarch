{-|
Module     : Monarch.Document
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Document
  ( Spec
  , bootstrap
  )
where

import Prelude

import Monarch.Html          ( Html )
import Monarch.Command       ( BASIC, MkHoist, mkHoist )
import Effect                ( Effect )
import Web.HTML              ( HTMLElement )
import Record                as Record
import Run                   ( Run )
import Type.Row              (type (+))

type Spec model message output effects a r
  = ( initialModel :: model
    , update       :: message -> model -> model
    , view         :: model -> Html message
    , container    :: HTMLElement
    , command      :: message -> model -> Run effects Unit
    , interpreter  :: Run effects a -> Run (BASIC message output ()) a
    , onOutput     :: output -> Effect Unit
    , subscription :: model -> Run effects Unit
    | r
    )

type DocumentSpec model message output effects a r
  = Spec model message output effects a
  + ( mkHoist :: MkHoist message output effects a | r )

foreign import document :: forall model message output effects a r. { | DocumentSpec model message output effects a r } -> Effect Unit

bootstrap :: forall model message output effects a. { | Spec model message output effects a () } -> Effect Unit
bootstrap spec = document $ Record.merge spec { mkHoist: mkHoist :: MkHoist message output effects a }
