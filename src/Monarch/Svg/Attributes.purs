module Monarch.Svg.Attributes where

import Type.Row (type (+))
import Monarch.VirtualDom.Attributes

newtype ViewBox = ViewBox { minX   :: Number
                          , minY   :: Number
                          , width  :: Number
                          , height :: Number
                          }

type SvgSvgElementAttributes r
  = GlobalAttributes
  + ( viewBox :: ViewBox
    | r
    )
