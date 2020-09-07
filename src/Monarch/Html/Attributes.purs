module Monarch.Html.Attributes where

import Type.Row    ( type (+) )
import Monarch.VirtualDom.Attributes

type HtmlDivElementAttributes r = GlobalAttributes r

type HtmlButtonElementAttributes r
  = GlobalAttributes
  + ( autofocus :: Boolean -- | Automatically focus the form control when the page is loaded
    , disabled  :: Boolean -- | Whether the form control is disabled
    | r
    )
