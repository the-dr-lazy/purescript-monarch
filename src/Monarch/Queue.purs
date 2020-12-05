{-|
Module     : Monarch.Queue
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

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
