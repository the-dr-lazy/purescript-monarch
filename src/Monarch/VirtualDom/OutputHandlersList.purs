module Monarch.VirtualDom.OutputHandlersList
  ( OutputHandlersList
  , nil
  )
where

import Prelude
import Effect

foreign import data OutputHandlersList :: Type

foreign import nil :: forall message. (message -> Effect Unit) -> OutputHandlersList
