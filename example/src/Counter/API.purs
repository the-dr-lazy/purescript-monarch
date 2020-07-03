module Counter.API where

import Prelude

import Effect.Class      ( liftEffect )
import Effect.Aff        ( Aff )
import Effect.Console    ( log )

increase :: Aff Unit
increase = liftEffect $ log "increase requested"

decrease :: Aff Unit
decrease = liftEffect $ log "decrease requested"
