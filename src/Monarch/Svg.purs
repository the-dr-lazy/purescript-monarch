{-|
Module     : Monarch.Svg
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Svg
  ( module Monarch.VirtualDom.VirtualDomTree.Prelude
  , svg
  )
where

import Monarch.Svg.Facts.Attributes
import Monarch.Svg.Facts.Outputs
import Monarch.Svg.Facts.Properties
import Monarch.VirtualDom.VirtualDomTree as VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree.Prelude

ns :: String
ns = "http://www.w3.org/2000/svg"

svg :: VirtualDomTree.Node SvgSvgElementProperties SvgSvgElementOutputs SvgSvgElementAttributes
svg facts children = VirtualDomTree.node { ns, tagName: "svg", facts, children }
