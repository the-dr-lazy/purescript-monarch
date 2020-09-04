module Monarch.VirtualDOM.Properties where

import Monarch.VirtualDOM.Attributes    ( ClassName )
import Type.Row                         ( type (+) )

type NodeProperties (r :: # Type) = r

type ElementProperties r
  = NodeProperties
  + ( className :: ClassName
    | r
    )

type HTMLElementProperties r = ElementProperties r

type HTMLDivElementProperties r = HTMLElementProperties r

type HTMLButtonElementProperties r
  = HTMLElementProperties
  + ( disabled :: Boolean
    | r
    )
