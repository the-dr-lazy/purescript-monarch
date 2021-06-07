{-|
Module     : Monarch.Queue
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
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
import Monarch.Event    ( Event (..), subscribe )
import Unsafe.Reference ( unsafeRefEq )
import Monarch.Monad.Maybe (whenJust)
import Data.Maybe

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

shareReplayLast :: forall a . Event a -> Effect (Event a)
shareReplayLast source = do
  lastValueRef <- Ref.new Nothing
  sink <- new
  unsubscribeSource <- source # subscribe \x -> do
    sink.dispatch x
    Ref.write (Just x) lastValueRef
  pure $ Event \next -> do
    Ref.read lastValueRef >>= whenJust next
    unsubscribeSink <- sink.event # subscribe next
    -- FIXME: unsubscribe from the source event
    pure $ unsubscribeSink
