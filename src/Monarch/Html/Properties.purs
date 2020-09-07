module Monarch.Html.Properties where

import Type.Row                         ( type (+) )
import Monarch.VirtualDom.Properties 

type HtmlElementProperties r = ElementProperties r

type HtmlDivElementProperties r = HtmlElementProperties r

type HtmlButtonElementProperties r
  = HtmlElementProperties
  + ( disabled :: Boolean
    | r
    )
