/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { Spec, unsafe_document } from '@purescript-monarch/core/Document'

interface Document {
    <model, message, output, effects>(spec: Spec<model, message, output, effects>): Effect<Unit>
}

export const document: Document = spec => () => unsafe_document(spec)
