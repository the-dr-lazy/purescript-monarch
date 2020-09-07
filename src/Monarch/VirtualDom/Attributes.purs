module Monarch.VirtualDom.Attributes where

import Prelude
import Data.Newtype

-- | A wrapper for strings which are used as CSS classes.
newtype ClassName = ClassName String

derive newtype instance eqClassName :: Eq ClassName
derive newtype instance ordClassName :: Ord ClassName
derive newtype instance semigroupClassName :: Semigroup ClassName

type GlobalAttributes r
  = ( class   :: ClassName       -- | Assigning class(es) to an element
    , classes :: Array ClassName -- | Assigning classes to an element
    | r
    )
