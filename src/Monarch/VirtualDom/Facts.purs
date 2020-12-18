module Monarch.VirtualDom.Facts where

import Type.Row (type (+))

type Facts (properties :: # Type -> # Type)
           (outputs    :: # Type -> # Type)
           (attributes :: # Type)
           (hooks      :: # Type)
  = properties
  + outputs
  + ( attributes :: { | attributes }
    , hooks      :: { | hooks }
    )
