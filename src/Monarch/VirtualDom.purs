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

foreign import mount :: forall key slots message. MountSpec -> VirtualDomTree key slots message -> Effect Unit

foreign import data DiffWork :: Type

foreign import mkDiffWork :: forall key key' slots a b. VirtualDomTree key slots a -> VirtualDomTree key' slots b -> DiffWork

type FinishDiffWorkSpec key slots message r
  = { rootVNode :: VirtualDomTree key slots message
    , rootPatchTree :: PatchTree
    | r
    }

type DiffWorkEnvironment key slots message r =
  { dispatchDiffWork :: DiffWork -> Effect Unit
  , finishDiffWork   :: FinishDiffWorkSpec key slots message r -> Effect Unit
  , scheduler        :: Scheduler
  }

foreign import performDiffWork :: forall key slots message r. DiffWorkEnvironment key slots message r -> DiffWork -> Effect Unit

foreign import applyPatchTree :: HTMLElement -> PatchTree -> Effect Unit

foreign import unmount :: forall key slots message. HTMLElement -> VirtualDomTree key slots message -> Effect Unit
