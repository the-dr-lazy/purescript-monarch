module Monarch.VirtualDOM.Outputs where

import Web.UIEvent.MouseEvent (MouseEvent)

type GlobalOutputs message r
  = ( onClick :: MouseEvent -> message
    | r
    )

type HTMLDivOutputs message r = GlobalOutputs message r

type HTMLButtonOutputs message r = GlobalOutputs message r
