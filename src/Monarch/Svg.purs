{-|
Module     : Monarch.Svg
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Svg
  ( module Monarch.VirtualDom.VirtualDomTree.Prelude
  , Svg
  , SVG
  , svg
  )
where

import Monarch.Svg.Facts.Attributes
import Monarch.Svg.Facts.Outputs
import Monarch.Svg.Facts.Properties
import Monarch.Type.Maybe
import Monarch.VirtualDom.Facts
import Monarch.VirtualDom.NS
import Monarch.VirtualDom.VirtualDomTree
import Monarch.VirtualDom.VirtualDomTree.Prelude
import Type.Proxy

foreign import data SVG  :: NS

instance IsNS SVG where
  reflectNS _ = "http://www.w3.org/2000/svg"

type Svg = VirtualDomTree Nothing ()

-- Elements

instance
  (MkFacts (SvgSvgElementProperties ())
           (SvgSvgElementOutputs message ())
           (SvgSvgElementAttributes ())
           message
           facts
  )
  => Facts SVG "svg" message facts

svg =
  node { ns: Proxy :: Proxy SVG
       , tagName: Proxy :: Proxy "svg"
       }
