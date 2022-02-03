{-|
Module     : Monarch.VirtualDom.Event.CustomEvent
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.Event.CustomEvent where

import Monarch.VirtualDom.Event.Handle
import Type.Proxy
import Type.Prelude
import Data.Variant as Variant
import Data.Variant (Variant)
import Type.Row as Row

foreign import foreign_mk
  :: forall bubbles composed detail
   . { name :: String
     , detail :: detail
     }
  -> CustomEventHandle detail

mk
  :: forall name detail bound_events unbound_events
   . IsSymbol name
  => Row.Cons name (CustomEventHandle detail) unbound_events bound_events
  => { name :: Proxy name
     , detail :: detail
     }
  -> Variant bound_events
mk { name, detail } = Variant.inj name event
  where event = foreign_mk { name: reflectSymbol name
                           , detail
                           }

class CustomEvent h where
  detail :: forall a. h a -> a

foreign import foreign_detail :: forall h a. h a -> a

instance CustomEvent CustomEventHandle where
  detail = foreign_detail
