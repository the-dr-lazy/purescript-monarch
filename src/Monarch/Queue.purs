module Monarch.Queue where

import Prelude
import Data.Traversable
import Data.Array       ( snoc
                        , deleteBy
                        )                 as Array
import Effect
import Effect.Ref                         as Ref
import Monarch.Event    ( Event (..) )
import Unsafe.Reference ( unsafeRefEq )

type Queue a
  = { event :: Event a
    , dispatch :: a -> Effect Unit
    }

new :: forall a. Effect (Queue a)
new = do
  nexts <- Ref.new []
  let
    modify = flip Ref.modify_ $ nexts
    push = modify <<< flip Array.snoc
    delete = modify <<< Array.deleteBy unsafeRefEq
    event = Event \next -> do
      push next
      pure $ delete next
    dispatch x = Ref.read nexts >>= traverse_ (_ $ x)
  pure { event, dispatch }
