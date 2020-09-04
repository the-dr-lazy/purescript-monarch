module Monarch.VirtualDOM.Properties where

import Monarch.VirtualDOM.Attributes    ( ClassName )
import Type.Row                         ( type (+) )

type NodeProperties r = r

type ElementProperties r
  = NodeProperties
  + ( className :: ClassName
    | r
    )

type HTMLElementProperties r = ElementProperties r

type HTMLDivProperties r = HTMLElementProperties r

type HTMLButtonProperties r
  = HTMLElementProperties
  + ( disabled :: Boolean
    | r
    )
