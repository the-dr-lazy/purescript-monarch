{-|
Module     : Monarch
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch
  ( module Monarch.Document
  , module Monarch.Platform
  )
where

import Monarch.Document
import Monarch.Platform ( Effects, Command, Upstream, dispatch, raise )
