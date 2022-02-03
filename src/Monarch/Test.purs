{-|
Module     : Test
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Test where

import Prelude
import Data.Maybe
import Effect

newtype TouchpointId = TouchpointId Int

foreign import data File :: Type

type Model = { touchpointId :: TouchpointId
             , file         :: Maybe File
             , state        :: State
             }

data State
  = BlankState
  | UploadingState (Effect Unit)
  | ReportState { confirmed :: Boolean, targets :: Array Row }

type BaseTarget r = ( id        :: Maybe String
                    , email     :: Maybe String
                    , firstName :: Maybe String
                    , lastName  :: Maybe String
                    , company   :: Maybe String
                    | r
                    )

newtype Phone = Phone String

data Target
  = AcceptedTarget             { | BaseTarget (phone :: Phone)  }
  | MissingPhoneNumberTarget   { | BaseTarget ()                }
  | InvalidPhoneNumberTarget   { | BaseTarget (phone :: String) }
  | DuplicatePhoneNumberTarget { | BaseTarget (phone :: Phone)  }
  | TimeGapViolationTarget     { | BaseTarget (phone :: Phone)  }

type Targets = Array Target

data Message
  = DownloadTemplate
  | Upload File
  | Abort
  | Uploading (Effect Unit)
  | Report Targets
  | ToggleConfirmation
  | Commit
  | Reject

update :: Message -> Model -> Model
update message model = case message, model of
  Uploading abort, _ -> model { state = UploadingState abort }

  Abort         , { state: UploadingState _ } -> model { file = Nothing }
  Report targets, { state: UploadingState _ } -> model { state = ReportState { confirmed: false, targets } }

  ToggleConfirmation, { state: ReportState { confirmed, groups } } ->
    model { state = ReportState { groups, confirmed: not confirmed } }
  Reject, { state: ReportState _ } -> model { state = BlankState }
  Commit, { state: ReportState _ } -> model { state = BlankState }

  _, _ -> model

foreign import download :: Effect Unit

handler :: Message -> Model -> Effect Unit
handler message model = case message, model of
  DownloadTemplate, _ -> pure unit
  Upload _, _ -> pure unit
  Abort, { state: UploadingState _ } -> pure unit
  Commit, { state: ReportState _ } -> pure unit
  Reject, { state: ReportState _ } -> pure unit
  _, _ -> pure unit

type Props = {}

view :: Props -> JSX
view {} =
  PXP.container
    { title: Html.text "Batch SMS Upload"
    , subTitle: Ant.button { type: Primary, onClick: const (dispatchMessage DownloadTemplate)}
    , children: [ Ant.Upload.dragger { className: ""
                                     , accept: ".csv"
                                     , fileList: [file]
                                     }
                ]
    }
