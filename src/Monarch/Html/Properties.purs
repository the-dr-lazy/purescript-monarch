module Monarch.Html.Properties where

import Type.Row                         ( type (+) )
import Monarch.VirtualDom.Properties 

type HTMLElementProperties r = ElementProperties r

type HTMLDivElementProperties r = HTMLElementProperties r

type HTMLButtonElementProperties r
  = HTMLElementProperties
  + ( disabled :: Boolean
    | r
    )
