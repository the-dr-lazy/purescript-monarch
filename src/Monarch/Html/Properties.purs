{-|
Module     : Monarch.Html.Properties
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Html.Properties where

import Monarch.Html.Attributes    ( ClassName )
import Type.Row                         ( type (+) )

type NodeProperties (r :: # Type) = r

type ElementProperties r
  = NodeProperties
  + ( className :: ClassName
    | r
    )

type HTMLElementProperties r = ElementProperties r

type HTMLDivElementProperties r = HTMLElementProperties r

type HTMLButtonElementProperties r
  = HTMLElementProperties
  + ( disabled :: Boolean
    | r
    )
