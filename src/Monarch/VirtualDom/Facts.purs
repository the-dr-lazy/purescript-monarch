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
class Facts ns tag_name message facts | ns tag_name message -> facts

class MkFacts :: Row Type -> Row Type -> Row Type -> Type -> Row Type -> Constraint
class MkFacts properties_type outputs_type attributes_type message facts | properties_type outputs_type attributes_type message -> facts

instance
  ( Row.Union3 properties_type outputs_type ( attributes :: { | attributes }, hooks :: { | hooks }, key :: key ) facts_type
  , Row.Union facts _facts facts_type
  , Row.OptionalRecordCons facts "attrs" attributes_type attributes
  , Row.OptionalRecordCons facts "hooks" (Hooks message) hooks
  )
  => MkFacts properties_type outputs_type attributes_type message facts
