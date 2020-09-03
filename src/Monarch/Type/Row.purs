module Monarch.Type.Row where

import Type.RowList (class RowToList)
import Monarch.Type.RowList as RowList

class OptionalRecordCons (row :: # Type) (name :: Symbol) (s :: # Type) (t :: # Type)

instance rowListOptionalRecordCons :: (RowToList row list, RowList.OptionalRecordCons list name s t) => OptionalRecordCons row name s t
