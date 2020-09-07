module Monarch.VirtualDom.Outputs where

import Web.UIEvent.MouseEvent (MouseEvent)

type GlobalOutputs message r
  = ( onClick :: MouseEvent -> message
    | r
    )

type ElementOutputs message r = GlobalOutputs message r
