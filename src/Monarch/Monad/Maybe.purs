module Monarch.Monad.Maybe where

import Prelude
import Data.Maybe

whenJust :: forall f a. Applicative f => Maybe a -> (a -> f Unit) -> f Unit
whenJust (Just x) f = f x
whenJust Nothing _  = pure unit

whenJustM :: forall m a. Monad m => m (Maybe a) -> (a -> m Unit) -> m Unit
whenJustM mm f = mm >>= \m -> whenJust m f
