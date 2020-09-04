module Monarch.VirtualDOM.Attributes where

import Prelude

import Type.Row    ( type (+) )

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

type HTMLDivElementAttributes r = GlobalAttributes r

type HTMLButtonElementAttributes r
  = GlobalAttributes
  + ( autofocus :: Boolean -- | Automatically focus the form control when the page is loaded
    , disabled  :: Boolean -- | Whether the form control is disabled
    | r
    )
