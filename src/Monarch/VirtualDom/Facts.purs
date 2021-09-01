{-|
Module     : Monarch.VirtualDom.Facts
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.VirtualDom.Facts
  ( class Facts
  , class MkFacts
  ) where

import Type.Row (type (+))
import Type.Row as Row
import Monarch.Type.Row as Row
import Monarch.VirtualDom.Facts.Hooks
import Monarch.VirtualDom.NS (NS)

class Facts :: NS -> Symbol -> Type -> Row Type -> Constraint
class Facts ns tagName message facts | ns tagName message -> facts

class MkFacts :: Row Type -> Row Type -> Row Type -> Type -> Row Type -> Constraint
class MkFacts propertiesType outputsType attributesType message facts | propertiesType outputsType attributesType message -> facts

instance mkFacts
  :: ( Row.Union3 propertiesType outputsType ( attributes :: { | attributes }, hooks :: { | hooks }, key :: keyType ) factsType
     , Row.Union facts _facts factsType
     , Row.OptionalRecordCons facts "attrs" attributesType attributes
     , Row.OptionalRecordCons facts "hooks" (Hooks message) hooks
     )
  => MkFacts propertiesType outputsType attributesType message facts
