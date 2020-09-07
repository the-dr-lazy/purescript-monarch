module Monarch.VirtualDom.Properties where

import Monarch.VirtualDom.Attributes    ( ClassName )
import Type.Row                         ( type (+) )

type NodeProperties (r :: # Type) = r

type ElementProperties r
  = NodeProperties
  + ( className :: ClassName
    | r
    )
