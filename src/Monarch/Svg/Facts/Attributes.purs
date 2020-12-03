{-|
Module     : Monarch.Svg.Facts.Attributes
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Svg.Facts.Attributes
  ( SvgSvgElementAttributes
  , ViewBox
  , mkViewBox
  )
where

import Prelude
import Type.Row (type (+))
import Data.String.Common as String
import Monarch.VirtualDom.Facts.Attributes

newtype ViewBox = ViewBox String

mkViewBox :: { minX :: Number
             , minY :: Number
             , width :: Number
             , height :: Number
             }
          -> ViewBox
mkViewBox { minX, minY, width, height } =
  ViewBox $ String.joinWith " " [show minX, show minY, show width, show height]

type SvgSvgElementAttributes r
  = GlobalAttributes
  + ( viewBox :: ViewBox
    | r
    )
