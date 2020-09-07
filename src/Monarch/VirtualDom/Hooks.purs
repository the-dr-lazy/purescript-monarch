module Monarch.VirtualDom.Hooks where

type Hooks message
  = ( init :: message
    )
