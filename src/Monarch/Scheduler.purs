{-|
Module     : Monarch.Scheduler
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Scheduler where

import Prelude
import Effect
import Effect.Ref as Ref

type Scheduler = { shouldYieldToBrowser :: Effect Boolean
                 , promoteDeadline :: Effect Unit
                 }

foreign import getCurrentTime :: Effect Number

mkScheduler :: Effect Scheduler
mkScheduler = do
  deadlineRef <- Ref.new 0.0
  pure { shouldYieldToBrowser: (>) <$> getCurrentTime <*> Ref.read deadlineRef
       , promoteDeadline: (_ + 5.0) <$> getCurrentTime >>= flip Ref.write deadlineRef
       }
