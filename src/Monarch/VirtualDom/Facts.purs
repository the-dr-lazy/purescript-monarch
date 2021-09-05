{-|
Module     : Monarch.VirtualDom.Facts
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.Facts where

import Type.Row (type (+))

type Facts :: (Row Type -> Row Type) -> (Row Type -> Row Type) -> Row Type -> Row Type -> Type -> Row Type -> Row Type
type Facts properties outputs attributes hooks key r
  = properties
  + outputs
  + ( attributes :: { | attributes }
    , hooks      :: { | hooks }
    , key        :: key
    | r
    )
