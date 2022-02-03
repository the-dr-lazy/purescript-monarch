/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import {
    unsafe_prepareFfiThrowEither,
    unsafe_prepareGlobalStates,
    unsafe_registerAndGetVirtualDomNodeMaker,
} from 'monarch/Monarch/State'
import { Spec } from 'monarch/Monarch/Element/Internal'

export function foreign_mkElement<model, message, event extends Event, effects>(
    spec: Spec<model, message, event, effects>,
) {
    unsafe_prepareGlobalStates()
    unsafe_prepareFfiThrowEither(spec.unLeft, spec.unRight)

    return unsafe_registerAndGetVirtualDomNodeMaker(spec)
}
