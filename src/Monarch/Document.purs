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
  ( CommonSpec
  , BootstrapSpec
  , bootstrap
  )
where

import Prelude
import Data.Maybe
import Data.Nullable
import Monarch.Html as Html
import Monarch.Command       ( BASIC, MkHoist, mkHoist )
import Effect                ( Effect )
import Web.HTML              ( HTMLElement )
import Record                as Record
import Run                   ( Run )
import Type.Row              (type (+))

type CommonSpec model message output effects a r
  = ( command      :: message -> model -> Run effects Unit
    , container    :: HTMLElement
    , initialModel :: model
    , interpreter  :: Run effects a -> Run (BASIC message output ()) a
    , onOutput     :: output -> Effect Unit
    , update       :: message -> model -> model
    , view         :: model -> Html.Root message
    | r
    )

type DocumentSpec model message output effects a r
  = CommonSpec model message output effects a
  + ( mkHoist :: MkHoist message output effects a
    , onInitialize :: Nullable message
    | r
    )

foreign import document :: forall model message output effects a r. { | DocumentSpec model message output effects a r } -> Effect Unit

type BootstrapSpec model message output effects a r
  = CommonSpec model message output effects a
  + ( onInitialize :: Maybe message | r )

bootstrap :: forall model message output effects a. { | BootstrapSpec model message output effects a () } -> Effect Unit
bootstrap spec = document $ Record.merge { mkHoist: mkHoist :: MkHoist message output effects a, onInitialize: toNullable spec.onInitialize } spec
