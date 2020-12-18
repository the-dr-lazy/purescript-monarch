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

import Monarch.VirtualDom.VirtualDomTree
import Monarch.VirtualDom.NS as NS
import Monarch.VirtualDom.VirtualDomTree.Prelude
import Monarch.Svg.Facts.Attributes
import Monarch.Svg.Facts.Properties
import Monarch.Svg.Facts.Outputs

-- Data Type

type Svg = VirtualDomTree NotKeyed ()

-- Elements

svg :: Node SvgSvgElementProperties SvgSvgElementOutputs SvgSvgElementAttributes
svg = nodeNS NS.SVG "svg"

svg_ :: Node_
svg_ = nodeNS_ NS.SVG "svg"

svg' :: forall message. Svg message
svg' = nodeNS' NS.SVG "svg"
