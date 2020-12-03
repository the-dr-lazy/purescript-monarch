{-|
Module     : Monarch.Svg
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
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
import Monarch.VirtualDom.VirtualDomTree as VirtualDomTree
import Monarch.VirtualDom.NS as NS
import Monarch.VirtualDom.Facts.Hooks
import Monarch.VirtualDom.VirtualDomTree.Prelude
import Monarch.Svg.Facts.Attributes
import Monarch.Svg.Facts.Properties
import Monarch.Svg.Facts.Outputs

-- Data Type

type Svg = VirtualDomTree' NS.SVG

-- Elements

type Node r slots message = VirtualDomTree.Node NS.SVG r slots message

type Node_ slots message = VirtualDomTree.Node_ NS.SVG slots message

type Leaf r slots message = VirtualDomTree.Leaf NS.SVG r slots message

type SvgSvgR attributes hooks message = R SvgSvgElementProperties (SvgSvgElementOutputs message) attributes hooks

svg :: forall r _r attributes hooks ns message
     . Row.Union r _r (SvgSvgR attributes hooks message)
    => Row.OptionalRecordCons r "attrs" (SvgSvgElementAttributes ()) attributes
    => Row.OptionalRecordCons r "hooks" (Hooks message) hooks
    => { | r }
    -> Array (Svg message)
    -> VirtualDomTree' ns message
svg = node "svg"

svg_ :: forall ns message. Array (Svg message) -> VirtualDomTree' ns message
svg_ = node "svg" {} 

svg' :: forall ns message. VirtualDomTree' ns message
svg' = node "svg" {} []
