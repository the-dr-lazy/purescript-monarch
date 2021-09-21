{-|
Module     : Monarch.Element
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2021 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Element where

import Data.Either
import Data.Maybe
import Monarch.Type.Maybe
import Prelude
import Type.Prelude
import Undefined
import Data.Nullable (Nullable, toNullable)
import Data.Nullable as Nullable
import Data.Traversable (sequence)
import Data.Variant (Variant)
import Effect (Effect)
import Effect.Class.Console (log)
import Monarch.Effect as Effect
import Monarch.Effect.Application (MkHoist, mkHoist)
import Monarch.Html as Html
import Monarch.Type.Row as Row
import Monarch.VirtualDom.Event.Handle (CustomEventHandle, MouseEventHandle)
import Monarch.VirtualDom.Facts (class EventNameToOutputKey)
import Monarch.VirtualDom.VirtualDomTree (VirtualDomTree, Slot)
import Prim.Symbol as Symbol
import Prim.TypeError as TypeError
import Record.Builder (Builder) as Record
import Record.Builder as Record.Builder
import Record.Unsafe.Union as Record
import Run (Run(..))
import Type.Data.Boolean (reflectBoolean)
import Type.Row (type (+))
import Type.Row as Row
import Type.RowList (RowList)
import Type.RowList as RowList
import Unsafe.Coerce (unsafeCoerce)
import Web.HTML.HTMLButtonElement (disabled)
import Data.Int as Int
import Data.Either as Either

-------------------------------------------------------
-- Property Reflection
--

class AsProperty a reflection | a -> reflection where
  fromProperty :: reflection -> Either String a
  toProperty   :: a -> reflection

instance AsProperty String String where
  fromProperty = Right
  toProperty = identity

instance AsProperty Int Number where
  fromProperty = undefined
  toProperty = undefined

instance AsProperty Number Number where
  fromProperty = Right
  toProperty = identity

instance AsProperty Boolean (Maybe Boolean) where
  fromProperty = pure <<< fromMaybe false
  toProperty = Just

instance AsProperty (Maybe a) (Maybe a) where
  fromProperty = pure
  toProperty = identity

-------------------------------------------------------
-- Attribute Reflection
--

class IsAttributeReflection :: Type -> Constraint
class IsAttributeReflection a
instance IsAttributeReflection String
instance IsAttributeReflection (Maybe String)

class (IsAttributeReflection reflection) <= AsAttribute a reflection | a -> reflection where
  fromAttribute :: reflection -> Either String a
  toAttribute   :: a -> reflection

instance AsAttribute String String where
  fromAttribute = Right
  toAttribute = identity

instance AsAttribute Int String where
  fromAttribute = Either.note "The value is not an integer." <<< Int.fromString
  toAttribute = show

instance AsAttribute Number String where
  fromAttribute = undefined
  toAttribute = show

instance AsAttribute Boolean (Maybe String) where
  fromAttribute = case _ of
    Nothing -> Right false
    Just "" -> Right false
    _       -> Right true

  toAttribute = case _ of
    false -> Nothing
    true  -> Just ""

instance (AsAttribute a String) => AsAttribute (Maybe a) (Maybe String) where
  fromAttribute = sequence <<< map fromAttribute
  toAttribute = map toAttribute

-------------------------------------------------------
-- Input Options
--

data Option

foreign import data Reflect      :: Option
foreign import data Don'tReflect :: Option
-- ToDo: foreign import data ReflectAs :: Symbol -> Option

class ShouldReflectInput :: RowList Option -> Symbol -> Boolean -> Constraint
class ShouldReflectInput options name result | options name -> result

instance ShouldReflectInput RowList.Nil _name False
instance ShouldReflectInput (RowList.Cons name Don'tReflect _options) name False
else instance ShouldReflectInput (RowList.Cons name Reflect _options) name True
else instance (ShouldReflectInput options name result) => ShouldReflectInput (RowList.Cons _name _option options) name result

-------------------------------------------------------
-- First Intermediate Representation
--
-- Association of the input type with the corresponding property reflection type.

data PreparedInputK

foreign import data PreparedInput
  :: Type    -- ^ Reference type
  -> Type    -- ^ Property reflection type
  -> Boolean -- ^ Whether reflect as an attribute or not.
  -> PreparedInputK

class PrepareInputs :: RowList Option -> RowList Type -> RowList PreparedInputK -> Constraint
class PrepareInputs options inputs prepared_inputs | options inputs -> prepared_inputs

instance PrepareInputs _options RowList.Nil RowList.Nil
instance
  ( AsProperty t property_reflection
  , PrepareInputs options inputs prepared_inputs
  , ShouldReflectInput options name should_reflect_as_attribute
  ) =>
  PrepareInputs
    options
    (RowList.Cons name t inputs)
    (RowList.Cons name (PreparedInput t property_reflection should_reflect_as_attribute) prepared_inputs)

-------------------------------------------------------
-- Second Intermediate Representation
--
-- Expansion of the input type to the required data for generation of the metadata.

data ExpandedInputK

foreign import data ExpandedInput
  :: Type    -- ^ Reference type
  -> Boolean -- ^ Whether reflect as an attribute or not.
  -> Boolean -- ^ Whether optional or not.
  -> ExpandedInputK

class ExpandPreparedInput :: PreparedInputK -> ExpandedInputK -> Constraint
class ExpandPreparedInput prepared_input expanded_input | prepared_input -> expanded_input

instance AsAttribute t (Maybe String) => ExpandPreparedInput (PreparedInput t (Maybe _a) True) (ExpandedInput t True True)
else instance AsAttribute t String => ExpandPreparedInput (PreparedInput t _property_reflection True) (ExpandedInput t True False)
instance ExpandPreparedInput (PreparedInput t (Maybe _a) False) (ExpandedInput t False True)
else instance ExpandPreparedInput (PreparedInput t _property_reflection False) (ExpandedInput t False False)

-------------------------------------------------------
-- Metadata Generation
--

newtype Metadatum a property_reflection attribute_reflection
  = Metadatum { optional      :: Boolean
              , fromAttribute :: attribute_reflection -> Either String a
              , toAttribute   :: a -> attribute_reflection
              , fromProperty  :: property_reflection -> Either String a
              , toProperty    :: a -> property_reflection
              }


class MkMetadata :: RowList ExpandedInputK -> Row Type -> Row Type -> Constraint
class MkMetadata expanded_inputs imetadata ometadata | expanded_inputs -> imetadata ometadata where
  mkMetadata :: Proxy expanded_inputs -> Record.Builder { | imetadata } { | ometadata }

instance MkMetadata RowList.Nil r r where
  mkMetadata _ = identity

instance
  ( AsProperty t property_reflection
  , AsAttribute t attribute_reflection
  , IsSymbol name
  , IsBoolean optional
  , Row.Lacks name imetadata
  , Row.Cons name (Metadatum t property_reflection attribute_reflection) imetadata metadata
  , MkMetadata expanded_inputs metadata ometadata
  ) =>
  MkMetadata (RowList.Cons name (ExpandedInput t True optional) expanded_inputs) imetadata ometadata where
  mkMetadata _ = Record.Builder.insert (Proxy :: Proxy name) metadatum >>> mkMetadata (Proxy :: Proxy expanded_inputs)
    where metadatum = Metadatum { optional: reflectBoolean (Proxy :: Proxy optional)
                                , fromAttribute
                                , toAttribute
                                , fromProperty
                                , toProperty
                                }

instance
  ( AsProperty t property_reflection
  , IsSymbol name
  , IsBoolean optional
  , Row.Lacks name imetadata
  , Row.Cons name (Metadatum t property_reflection attribute_reflection) imetadata metadata
  , MkMetadata expanded_inputs metadata ometadata
  ) =>
  MkMetadata (RowList.Cons name (ExpandedInput t False optional) expanded_inputs) imetadata ometadata where
  mkMetadata _ = Record.Builder.insert (Proxy :: Proxy name) metadatum >>> mkMetadata (Proxy :: Proxy expanded_inputs)
    where metadatum = Metadatum { optional: reflectBoolean (Proxy :: Proxy optional)
                                , fromAttribute: undefined
                                , toAttribute: undefined
                                , fromProperty
                                , toProperty
                                }

type CommonSpec inputs model message events effects slots r
  = ( command        :: message -> model -> Run effects Unit
    , mkInitialModel :: { | inputs } -> Effect model
    , interpreter    :: Run effects ~> Run (Effect.Basic message (Variant events) ())
    , update         :: message -> model -> model
    , view           :: model -> Html.Host slots message
    , tagName        :: String
    | r
    )

type ForeignMkElementSpec input model message events effects slots r
  = CommonSpec input model message events effects slots
  + ( mkHoist :: forall a. MkHoist message (Variant events) effects a
    , onInitialize :: Nullable message
    , onFinalize :: Nullable message
    , onInputChange :: Nullable ({ | input } -> message)
    , metadata :: forall metadata. { | metadata }
    , unLeft :: forall e a. Either e a -> Nullable e
    , unRight :: forall e a. Either e a -> Nullable a
    | r
    )

foreign import foreign_mkElement
  :: forall input model message events effects facts child substituted_slot downstream_slots key
   . { | ForeignMkElementSpec input model message events effects downstream_slots () }
  -> { | facts }
  -> { | child }
  -> VirtualDomTree substituted_slot downstream_slots key message

-------------------------------------------------------
--
--

class DeriveChildrenFromSlots :: forall r. Row Type -> Type -> r Type -> r Type -> r Type -> Constraint
class DeriveChildrenFromSlots downstream_slots message slots optional_children required_children | downstream_slots message slots -> optional_children required_children

instance DeriveChildrenFromSlots _downstream_slots _message RowList.Nil RowList.Nil RowList.Nil
else instance
  DeriveChildrenFromSlots downstream_slots message slots optional_children required_children =>
  DeriveChildrenFromSlots
    downstream_slots

    message
    (RowList.Cons name (Maybe Slot) slots)
    (RowList.Cons name (VirtualDomTree name downstream_slots Nothing message) optional_children)
    required_children
else instance
  DeriveChildrenFromSlots downstream_slots message slots optional_children required_children =>
  DeriveChildrenFromSlots
    downstream_slots

    message
    (RowList.Cons name (Array Slot) slots)
    (RowList.Cons name (Array (VirtualDomTree name downstream_slots key message)) optional_children)
    required_children
else instance
  DeriveChildrenFromSlots downstream_slots message slots optional_children required_children =>
  DeriveChildrenFromSlots
    downstream_slots

    message
    (RowList.Cons name Slot slots)
    optional_children
    (RowList.Cons name (VirtualDomTree name downstream_slots Nothing message) required_children)
else instance
  ( RowToList rslots slots
  , DeriveChildrenFromSlots downstream_slots message slots optional_children required_children
  , ListToRow optional_children roptional_children
  , ListToRow required_children rrequired_children
  ) =>
  DeriveChildrenFromSlots downstream_slots message rslots roptional_children rrequired_children

type Element optional_facts required_facts events slots
  = forall outputs optional_facts' bound_optional_facts unbound_optional_facts bound_facts optional_children required_children bound_optional_children unbound_optional_children bound_children downstream_slots substituted_slot key message
  . Row.Union optional_facts outputs optional_facts'
 => Row.Union bound_optional_facts unbound_optional_facts optional_facts'
 => Row.Union required_facts bound_optional_facts bound_facts
 => DeriveChildrenFromSlots downstream_slots message slots optional_children required_children
 => Row.Union bound_optional_children unbound_optional_children optional_children
 => Row.Union required_children bound_optional_children bound_children
 => { | bound_facts }
 -> { | bound_children }
 -> VirtualDomTree substituted_slot downstream_slots key message

-------------------------------------------------------
--
--

class DerivationsFromPreparedInputs
  :: RowList PreparedInputK -- ^ Prepared inputs
  -> RowList Type           -- ^ Optional inputs
  -> RowList Type           -- ^ Required inputs
  -> RowList ExpandedInputK -- ^ Expanded properties
  -> Constraint
class DerivationsFromPreparedInputs
  prepared_inputs optional_inputs required_inputs expanded_inputs | prepared_inputs -> optional_inputs required_inputs expanded_inputs

instance DerivationsFromPreparedInputs RowList.Nil RowList.Nil RowList.Nil RowList.Nil
instance
  ( ExpandPreparedInput (PreparedInput t (Maybe a) should_reflect_as_attribute) expanded_input
  , DerivationsFromPreparedInputs
      prepared_inputs
      optional_inputs
      required_inputs
      expanded_inputs
  ) =>
  DerivationsFromPreparedInputs
    (RowList.Cons name (PreparedInput t (Maybe a) should_reflect_as_attribute) prepared_inputs)
    (RowList.Cons name t optional_inputs)
    required_inputs
    (RowList.Cons name expanded_input expanded_inputs)
else instance
  ( ExpandPreparedInput (PreparedInput t property_reflection should_reflect_as_attribute) expanded_input
  , DerivationsFromPreparedInputs
      prepared_inputs
      optional_inputs
      required_inputs
      expanded_inputs
  ) =>
  DerivationsFromPreparedInputs
    (RowList.Cons name (PreparedInput t property_reflection should_reflect_as_attribute) prepared_inputs)
    optional_inputs
    (RowList.Cons name t required_inputs)
    (RowList.Cons name expanded_input expanded_inputs)

type MkElementSpec
  :: Row Option
  -> Row Type
  -> Type
  -> Type
  -> Row Type
  -> Row (Type -> Type)
  -> Row Type
  -> Row Type
  -> Row Type
type MkElementSpec options inputs model message events effects slots r
  = CommonSpec inputs model message events effects slots
  + ( onInitialize  :: Maybe message
    , onFinalize    :: Maybe message
    , onInputChange :: Maybe ({ | inputs } -> message)
    , options       :: Proxy options
    | r
    )

mkElement
  :: forall loptions options linputs inputs prepared_inputs loptional_inputs optional_inputs lrequired_inputs required_inputs expanded_inputs model message events effects slots metadata
   . RowToList options loptions
  => RowToList inputs linputs
  => PrepareInputs loptions linputs prepared_inputs
  => DerivationsFromPreparedInputs prepared_inputs loptional_inputs lrequired_inputs expanded_inputs
  => ListToRow loptional_inputs optional_inputs
  => ListToRow lrequired_inputs required_inputs
  => MkMetadata expanded_inputs () metadata
  => { | MkElementSpec options inputs model message events effects slots () }
  -> Element optional_inputs required_inputs events slots
mkElement spec = foreign_mkElement (Record.unsafeUnion override spec)
  where override = { metadata: Record.Builder.buildFromScratch (mkMetadata (Proxy :: Proxy expanded_inputs))
                   , mkHoist
                   , unLeft
                   , unRight
                   , onInitialize: toNullable spec.onInitialize
                   , onFinalize: toNullable spec.onFinalize
                   , onInputChange: toNullable spec.onInputChange
                   , maybeToNullable: toNullable
                   , nullableToMaybe: Nullable.toMaybe
                   , nothing: Nothing
                   }

unLeft :: forall e a. Either e a -> Nullable e
unLeft = case _ of
  Left e -> Nullable.notNull e
  Right _ -> Nullable.null

unRight :: forall e a. Either e a -> Nullable a
unRight = case _ of
  Left _ -> Nullable.null
  Right a -> Nullable.notNull a
