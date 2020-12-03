{-|
Module     : Monarch.VirtualDom
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
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
import Monarch.VirtualDom.NS (kind NS)
import Monarch.VirtualDom.NS as NS
import Monarch.VirtualDom.VirtualDomTree
import Monarch.VirtualDom.PatchTree
import Monarch.VirtualDom.OutputHandlerTree
import Monarch.Scheduler

type MountSpec
  = { container :: HTMLElement
    , rootOutputHandlerNode :: OutputHandlerTree
    }

foreign import mount :: forall slots message. MountSpec -> VirtualDomTree NS.HTML slots message -> Effect Unit

foreign import data DiffWork :: Type
                    
foreign import mkDiffWork :: forall ns slots a b. VirtualDomTree ns slots a -> VirtualDomTree ns slots b -> DiffWork

type FinishDiffWorkSpec slots message r
  = { rootVNode :: VirtualDomTree NS.HTML slots message
    , rootPatchTree :: PatchTree
    | r
    }

type DiffWorkEnvironment slots message r =
  { dispatchDiffWork :: DiffWork -> Effect Unit
  , finishDiffWork   :: FinishDiffWorkSpec slots message r -> Effect Unit
  , scheduler        :: Scheduler
  }

foreign import performDiffWork :: forall slots message r. DiffWorkEnvironment slots message r -> DiffWork -> Effect Unit

foreign import applyPatchTree :: HTMLElement -> PatchTree -> Effect Unit

foreign import unmount :: forall slots message. HTMLElement -> VirtualDomTree NS.HTML slots message -> Effect Unit

                          
