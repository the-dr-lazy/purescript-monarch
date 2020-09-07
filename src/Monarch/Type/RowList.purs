module Monarch.Type.RowList where

import Type.RowList (kind RowList)
import Type.RowList as RowList
import Type.Row as Row

-- | `RowList` version of `OptionalRecordCons` typeclass
class OptionalRecordCons (row :: RowList) (name :: Symbol) (s :: # Type) (t :: # Type)

instance nilOptionalRecordCons :: OptionalRecordCons RowList.Nil _name _s _t
-- | Constraint target field (`name`) when it exists on given `row`
instance consOptionalRecordCons ::
  (Row.Union t _t s) => OptionalRecordCons (RowList.Cons name { | t } tail) name s t
else instance fallbackConsOptionalRecordCons ::
  (OptionalRecordCons tail name s t) => OptionalRecordCons (RowList.Cons _name _t tail) name s t
