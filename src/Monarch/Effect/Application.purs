{-|
Module     : Monarch.Effect.Application
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Effect.Application
  ( Application
  , ApplicationF
  , MkHoist
  , dispatch
  , mkHoist
  , raise
  , run
  , Basic
  )
where

import Prelude
import Type.Proxy
import Effect
import Effect.Aff (launchAff_)
import Run (Run, EFFECT, AFF, runBaseAff', interpret)
import Run as Run
import Type.Row (type (+))

data ApplicationF message output a
  = Dispatch message a
  | Raise output a

derive instance functorApplicationF :: Functor (ApplicationF message output)

_effect = Proxy :: Proxy "application"

type Application message output r = (application :: ApplicationF message output | r)

type Basic message output r
  = EFFECT
  + AFF
  + Application message output
  + r

dispatch :: forall message output r. message -> Run (Application message output + r) Unit
dispatch message = Run.lift _effect (Dispatch message unit)

raise :: forall message output r. output -> Run (Application message output + r) Unit
raise output = Run.lift _effect (Raise output unit)

run
  :: forall message output r
   . (message -> Effect Unit)
  -> (output -> Effect Unit)
  -> Run (Application message output + EFFECT + r)
  ~> Run (EFFECT + r)
run dispatchMessage dispatchOutput = interpret (Run.on _effect go Run.send)
  where
    go :: ApplicationF message output ~> Run (EFFECT + r)
    go = case _ of
      Dispatch message next -> Run.liftEffect $ dispatchMessage message *> pure next
      Raise    output  next -> Run.liftEffect $ dispatchOutput output   *> pure next

type MkHoist message output effects a
  = { interpreter     :: Run effects a -> Run (Basic message output ()) a
    , dispatchMessage :: message -> Effect Unit
    , dispatchOutput  :: output -> Effect Unit
    }
 -> Run effects a
 -> Effect Unit

mkHoist :: forall message output effects a. MkHoist message output effects a
mkHoist { interpreter, dispatchMessage, dispatchOutput } program =
  launchAff_ <<< runBaseAff' <<< run dispatchMessage dispatchOutput <<< interpreter $ program
