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
  , document_
  )
where

import Prelude

import Monarch.Html          ( Html )
import Monarch.Command       ( BASIC )
import Monarch.Command       as Command
import Effect                ( Effect )
import Web.HTML              ( HTMLElement )
import Run                   ( Run )

type Document output
  = { output :: (output -> Effect Unit) -> Effect Unit
    }

type DocumentImplementaionSpec input model message output r
  = ( input      :: input
    , init       :: input -> model
    , update     :: message -> model -> model
    , view       :: model -> Html message
    , container  :: HTMLElement
    , runCommand :: message -> model -> (message -> Effect Unit) -> (output -> Effect Unit) -> Effect Unit
    | r
    )

foreign import documentImpl :: forall input model message output r. { | DocumentImplementaionSpec input model message output r } -> Effect (Document output)

type Spec input model message output effects a r
  = ( input       :: input
    , init        :: input -> model
    , update      :: message -> model -> model
    , view        :: model -> Html message
    , container   :: HTMLElement
    , command     :: message -> model -> Run effects a
    , interpreter :: Run effects a -> Run (BASIC message output ()) Unit
    | r
    )

document :: forall input model message output effects a r. { | Spec input model message output effects a r } -> Effect (Document output)
document spec = do
  documentImpl
    { input: spec.input, init: spec.init, update: spec.update, view: spec.view, container: spec.container, runCommand: Command.run spec.command spec.interpreter }

document_ :: forall input model message output effects a r. { | Spec input model message output effects a r } -> Effect Unit
document_ = void <<< document
