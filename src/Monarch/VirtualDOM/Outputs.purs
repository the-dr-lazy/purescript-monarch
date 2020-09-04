module Monarch.VirtualDOM.Outputs where

import Web.UIEvent.MouseEvent (MouseEvent)

type GlobalOutputs message r
  = ( onClick :: MouseEvent -> message
    | r
    )

type ElementOutputs message r = GlobalOutputs message r

type HTMLElementOutputs message r = ElementOutputs message r

type HTMLDivElementOutputs message r = HTMLElementOutputs message r

type HTMLButtonElementOutputs message r = HTMLElementOutputs message r
