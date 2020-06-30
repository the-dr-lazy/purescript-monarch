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
