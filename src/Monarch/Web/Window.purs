{-|
Module     : Monarch.Web.Window
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Web.Window where

import Prelude
import Data.Newtype
import Effect

foreign import setTimeout :: Int -> Effect Unit -> Effect Int

foreign import clearTimeout :: Int -> Effect Unit

newtype TimeoutId = TimeoutId Int

derive instance newtypeTimeoutId :: Newtype TimeoutId _
derive instance eqTimeoutId :: Eq TimeoutId
derive instance ordTimeoutId :: Ord TimeoutId

requestTimeout :: Int -> Effect Unit -> Effect TimeoutId
requestTimeout n = map TimeoutId <<< setTimeout n

cancelTimeout :: TimeoutId -> Effect Unit
cancelTimeout = clearTimeout <<< unwrap

foreign import setInterval :: Int -> Effect Unit -> Effect Int

foreign import clearInterval :: Int -> Effect Unit

newtype IntervalId = IntervalId Int

derive instance newtypeIntervalId :: Newtype IntervalId _
derive instance eqIntervalId :: Eq IntervalId
derive instance ordIntervalId :: Ord IntervalId

requestInterval :: Int -> Effect Unit -> Effect IntervalId
requestInterval n = map IntervalId <<< setInterval n

cancelInterval :: IntervalId -> Effect Unit
cancelInterval = clearInterval <<< unwrap

foreign import _requestAnimationFrame :: Effect Unit -> Effect Int

foreign import _cancelAnimationFrame :: Int -> Effect Unit

newtype AnimationFrameId = AnimationFrameId Int

derive instance newtypeAnimationFrameId :: Newtype AnimationFrameId _
derive instance eqAnimationFrameId :: Eq AnimationFrameId
derive instance ordAnimationFrameId :: Ord AnimationFrameId

requestAnimationFrame :: Effect Unit -> Effect AnimationFrameId
requestAnimationFrame = map AnimationFrameId <<< _requestAnimationFrame

cancelAnimationFrame :: AnimationFrameId -> Effect Unit
cancelAnimationFrame = _cancelAnimationFrame <<< unwrap

foreign import _requestIdleCallback :: Int -> Effect Unit -> Effect Int

foreign import _cancelIdleCallback :: Int -> Effect Unit

newtype IdleCallbackId = IdleCallbackId Int

derive instance newtypeIdleCallbackId :: Newtype IdleCallbackId _
derive instance eqIdleCallbackId :: Eq IdleCallbackId
derive instance ordIdleCallbackId :: Ord IdleCallbackId

requestIdleCallback :: Int -> Effect Unit -> Effect IdleCallbackId
requestIdleCallback n = map IdleCallbackId <<< _requestIdleCallback n

requestIdleCallback' :: Effect Unit -> Effect IdleCallbackId
requestIdleCallback' = requestIdleCallback 0

cancelIdleCallback :: IdleCallbackId -> Effect Unit
cancelIdleCallback = _cancelIdleCallback <<< unwrap

-- Request Immediate

foreign import _requestImmediate :: Effect Unit -> Effect Int

foreign import _cancelImmediate :: Int -> Effect Unit

newtype ImmediateId = ImmediateId Int

derive instance newtypeImmediateId :: Newtype ImmediateId _
derive instance eqImmediateId :: Eq ImmediateId
derive instance ordImmediateId :: Ord ImmediateId

requestImmediate :: Effect Unit -> Effect ImmediateId
requestImmediate = map ImmediateId <<< _requestImmediate

cancelImmediate :: ImmediateId -> Effect Unit
cancelImmediate = _cancelImmediate <<< unwrap
