{-|
Module     : Monarch.VirtualDom
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom where

import Prelude
import Effect (Effect)
import Type.Row                         ( type (+) )
import Web.HTML                         ( HTMLElement )
import Monarch.VirtualDom.VirtualDomTree
import Monarch.VirtualDom.PatchTree
import Monarch.VirtualDom.OutputHandlersList
import Monarch.Scheduler

type MountSpec
  = { container      :: HTMLElement
    , outputHandlers :: OutputHandlersList
    }

foreign import mount :: forall isKeyed slots message. MountSpec -> VirtualDomTree isKeyed slots message -> Effect Unit

foreign import data DiffWork :: Type

foreign import mkDiffWork :: forall isKeyed _isKeyed slots a b. VirtualDomTree isKeyed slots a -> VirtualDomTree _isKeyed slots b -> DiffWork

type FinishDiffWorkSpec isKeyed slots message r
  = { rootVNode :: VirtualDomTree isKeyed slots message
    , rootPatchTree :: PatchTree
    | r
    }

type DiffWorkEnvironment isKeyed slots message r =
  { dispatchDiffWork :: DiffWork -> Effect Unit
  , finishDiffWork   :: FinishDiffWorkSpec isKeyed slots message r -> Effect Unit
  , scheduler        :: Scheduler
  }

foreign import performDiffWork :: forall isKeyed slots message r. DiffWorkEnvironment isKeyed slots message r -> DiffWork -> Effect Unit

foreign import applyPatchTree :: HTMLElement -> PatchTree -> Effect Unit

foreign import unmount :: forall isKeyed slots message. HTMLElement -> VirtualDomTree isKeyed slots message -> Effect Unit
