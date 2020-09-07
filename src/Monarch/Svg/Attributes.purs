module Monarch.Svg.Attributes
  ( SvgSvgElementAttributes
  , ViewBox
  , mkViewBox
  )
where

import Prelude
import Type.Row (type (+))
import Data.String.Common as String
import Monarch.VirtualDom.Attributes

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
