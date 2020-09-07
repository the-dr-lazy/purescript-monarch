module Monarch.Html.Attributes where

import Type.Row    ( type (+) )
import Monarch.VirtualDom.Attributes

type HTMLDivElementAttributes r = GlobalAttributes r

type HTMLButtonElementAttributes r
  = GlobalAttributes
  + ( autofocus :: Boolean -- | Automatically focus the form control when the page is loaded
    , disabled  :: Boolean -- | Whether the form control is disabled
    | r
    )
