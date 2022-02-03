{-|
Module     : Monarch.Html
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Html
  ( module Monarch.VirtualDom.VirtualDomTree.Prelude
  , Root
  , div
  , button
  , Host
  , class Slot
  , slot
  )
where

import Monarch.Html.Facts.Attributes
import Monarch.Html.Facts.Outputs
import Monarch.Html.Facts.Properties
import Monarch.Type.Maybe
import Monarch.Type.Maybe
import Monarch.VirtualDom.Facts
import Monarch.VirtualDom.Facts.Hooks
import Monarch.VirtualDom.Facts.Hooks
import Monarch.VirtualDom.VirtualDomTree.Prelude
import Type.Prelude
import Undefined

import Monarch.Type.Row as Row
import Monarch.VirtualDom.Slots as Slots
import Monarch.VirtualDom.VirtualDomTree (VirtualDomTree)
import Monarch.VirtualDom.VirtualDomTree as VirtualDomTree
import Type.Equality (class TypeEquals)
import Type.Row as Row
import Type.RowList as RowList
import Unsafe.Coerce
import Record.Unsafe.Union as Record


type Root message = forall substituted_slot. VirtualDomTree substituted_slot () Nothing message

div :: VirtualDomTree.Node HtmlDivElementProperties HtmlDivElementOutputs HtmlDivElementAttributes
div facts children = VirtualDomTree.node { ns: undefined, tagName: "div", facts, children }

button :: VirtualDomTree.Node HtmlButtonElementProperties HtmlButtonElementOutputs HtmlButtonElementAttributes
button facts children = VirtualDomTree.node { ns: undefined, tagName: "button", facts, children }

type Host downstream_slots message = forall substituted_slot. VirtualDomTree substituted_slot downstream_slots Nothing message

class Slot return where
  slot :: return

instance
  ( ExtractSlotNameFromFacts bound_facts slot_name
  , IsSymbol slot_name
  , Row.Cons slot_name (Maybe VirtualDomTree.Slot) _downstream_slots downstream_slots
  , Row.Union bound_facts unbound_facts (Facts (HtmlSlotElementProperties name) (HtmlSlotElementOutputs message) bound_attributes bound_hooks)
  , Row.OptionalRecordCons bound_facts "attrs" (HtmlSlotElementAttributes ()) bound_attributes
  , Row.OptionalRecordCons bound_facts "hooks" (Hooks message) bound_hooks
  , TypeEquals child (VirtualDomTree Slots.Default downstream_slots child_key message)
  , TypeEquals return (VirtualDomTree substituted_slot downstream_slots Nothing message)
  ) =>
  Slot ({ | bound_facts } -> Array child -> return) where
  slot facts = unsafeCoerce \children -> (VirtualDomTree.node { ns: undefined, tagName: "slot", facts: Record.unsafeUnion { name: reflectSymbol (Proxy :: Proxy slot_name) } facts, children })


else instance
  ( ExtractSlotNameFromFacts bound_facts slot_name
  , IsSymbol slot_name
  , Row.Cons slot_name (Array VirtualDomTree.Slot) _downstream_slots downstream_slots
  , Row.Union bound_facts unbound_facts (Facts (HtmlSlotElementProperties name) (HtmlSlotElementOutputs message) bound_attributes bound_hooks)
  , Row.OptionalRecordCons bound_facts "attrs" (HtmlSlotElementAttributes ()) bound_attributes
  , Row.OptionalRecordCons bound_facts "hooks" (Hooks message) bound_hooks
  , TypeEquals return (VirtualDomTree substituted_slot downstream_slots Nothing message)
  ) =>
  Slot ({ | bound_facts } -> (Array return)) where
  slot facts = unsafeCoerce [ VirtualDomTree.node { ns: undefined, tagName: "slot", facts: Record.unsafeUnion { name: reflectSymbol (Proxy :: Proxy slot_name) } facts, children: undefined } ]

else instance
  ( ExtractSlotNameFromFacts bound_facts slot_name
  , IsSymbol slot_name
  , Row.Cons slot_name VirtualDomTree.Slot _downstream_slots downstream_slots
  , Row.Union bound_facts unbound_facts (Facts (HtmlSlotElementProperties name) (HtmlSlotElementOutputs message) bound_attributes bound_hooks)
  , Row.OptionalRecordCons bound_facts "attrs" (HtmlSlotElementAttributes ()) bound_attributes
  , Row.OptionalRecordCons bound_facts "hooks" (Hooks message) bound_hooks
  , TypeEquals return (VirtualDomTree substituted_slot downstream_slots Nothing message)
  ) =>
  Slot ({ | bound_facts } -> return) where
  slot = unsafeCoerce \facts -> (VirtualDomTree.node { ns: undefined, tagName: "slot", facts: Record.unsafeUnion { name: reflectSymbol (Proxy :: Proxy slot_name) } facts, children: undefined })

else instance
  ( Row.Cons Slots.Default (Array VirtualDomTree.Slot) _downstream_slots downstream_slots
  , TypeEquals return (VirtualDomTree substituted_slot downstream_slots Nothing message)
  ) =>
  Slot (Array return) where
  slot = unsafeCoerce [ VirtualDomTree.node { ns: undefined, tagName: "slot", facts: undefined, children: undefined } ]

else instance
  ( Row.Cons Slots.Default VirtualDomTree.Slot _downstream_slots downstream_slots
  , TypeEquals return (VirtualDomTree substituted_slot downstream_slots Nothing message)
  ) =>
  Slot return where
  slot = unsafeCoerce (VirtualDomTree.node { ns: undefined, tagName: "slot", facts: undefined, children: undefined })
