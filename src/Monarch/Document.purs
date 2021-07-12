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
  , document
  )
where

import Prelude

import Monarch.Html          ( Html )
import Effect                ( Effect )
import Web.HTML              ( HTMLElement )

type Spec input model message r
  = ( input     :: input
    , init      :: input -> model
    , update    :: message -> model -> model
    , view      :: model -> Html message
    , container :: HTMLElement
    | r
    )

foreign import document :: forall input model message r. { | Spec input model message r } -> Effect Unit
