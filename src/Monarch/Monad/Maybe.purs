module Monarch.Monad.Maybe where

import Prelude
import Data.Maybe

whenJust :: forall f a. Applicative f => (a -> f Unit) -> Maybe a -> f Unit
whenJust f (Just x) = f x
whenJust _ Nothing  = pure unit

whenJustM :: forall m a. Monad m => (a -> m Unit) -> m (Maybe a) -> m Unit
whenJustM f mm = mm >>= whenJust f
