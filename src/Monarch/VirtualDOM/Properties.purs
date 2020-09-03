module Monarch.VirtualDOM.Properties where

import Monarch.VirtualDOM.Attributes    ( ClassName )
import Type.Row                         ( type (+) )

type GlobalProperties r
  = ( className :: ClassName
    | r
    )

type HTMLDivProperties r = GlobalProperties r

type HTMLButtonProperties r
  = GlobalProperties
  + ( disabled :: Boolean
    | r
    )
