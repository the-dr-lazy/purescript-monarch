{-|
Module     : Monarch.Application
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Application
  ( CommonSpec
  , MkApplicationSpec
  , mkApplication
  )
where

import Prelude
import Data.Maybe
import Data.Nullable
import Monarch.Html as Html
import Monarch.Effect as Effect
import Monarch.Effect.Application (MkHoist, mkHoist)
import Effect                ( Effect )
import Web.HTML              ( HTMLElement )
import Record                as Record
import Run                   ( Run )
import Type.Row              (type (+))

type CommonSpec model message output effects a r
  = ( command      :: message -> model -> Run effects Unit
    , container    :: HTMLElement
    , initialModel :: model
    , interpreter  :: Run effects a -> Run (Effect.Basic message output ()) a
    , onOutput     :: output -> Effect Unit
    , update       :: message -> model -> model
    , view         :: model -> Html.Root message
    | r
    )

type ForeignMkApplicationSpec model message output effects a r
  = CommonSpec model message output effects a
  + ( mkHoist :: MkHoist message output effects a
    , onInitialize :: Nullable message
    | r
    )

foreign import foreign_mkApplication :: forall model message output effects a r. { | ForeignMkApplicationSpec model message output effects a r } -> Effect Unit

type MkApplicationSpec model message output effects a r
  = CommonSpec model message output effects a
  + ( onInitialize :: Maybe message | r )

mkApplication :: forall model message output effects a. { | MkApplicationSpec model message output effects a () } -> Effect Unit
mkApplication spec = foreign_mkApplication $ Record.merge { mkHoist: mkHoist :: MkHoist message output effects a, onInitialize: toNullable spec.onInitialize } spec
