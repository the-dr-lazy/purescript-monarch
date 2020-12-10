{-|
Module     : Monarch.Svg
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Svg
  ( module Monarch.VirtualDom.VirtualDomTree.Prelude
  , Svg
  , svg , svg_, svg'
  )
where

import Type.Row as Row
import Monarch.Type.Row as Row
import Monarch.VirtualDom.VirtualDomTree
import Monarch.VirtualDom.NS as NS
import Monarch.VirtualDom.Facts.Hooks
import Monarch.VirtualDom.VirtualDomTree.Prelude
import Monarch.Svg.Facts.Attributes
import Monarch.Svg.Facts.Properties
import Monarch.Svg.Facts.Outputs

-- Data Type

type Svg = VirtualDomTree ()

-- Elements

type SvgSvgR attributes hooks message = R SvgSvgElementProperties (SvgSvgElementOutputs message) attributes hooks

svg :: forall r _r attributes hooks slots message
     . Row.Union r _r (SvgSvgR attributes hooks message)
    => Row.OptionalRecordCons r "attrs" (SvgSvgElementAttributes ()) attributes
    => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
    => Node r slots message
svg = nodeNS NS.SVG "svg"

svg_ :: forall slots message. Node_ slots message
svg_ = nodeNS_ NS.SVG "svg"

svg' :: forall message. Svg message
svg' = nodeNS' NS.SVG "svg"
