/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2021 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { mkCustomElement, Spec } from 'monarch/Monarch/Element/Internal'
import { customNode } from 'monarch/Monarch/VirtualDom/VirtualDomTree'

declare global {
    interface Window {
        __MONARCH_UNSAFE_FFI?: FFI
        __MONARCH_UNSAFE_CUSTOM_ELEMENT_MAKERS_REGISTERY?: CustomElementMakersRegistery
    }
}

interface FFI {
    unsafe_throwEither?: <e, a>(either: Either<e, a>) => a
}

interface CustomElementMakersRegistery {
    [tagName: string]: any
}

export function unsafe_prepareGlobalStates() {
    if (window.__MONARCH_UNSAFE_FFI === undefined) window.__MONARCH_UNSAFE_FFI = {}
    if (window.__MONARCH_UNSAFE_CUSTOM_ELEMENT_MAKERS_REGISTERY === undefined)
        window.__MONARCH_UNSAFE_CUSTOM_ELEMENT_MAKERS_REGISTERY = {}
}

export function unsafe_prepareFfiThrowEither(
    unLeft: <e, a>(evalue: Either<e, a>) => Nullable<e>,
    unRight: <e, a>(evalue: Either<e, a>) => Nullable<a>,
): void {
    if (window.__MONARCH_UNSAFE_FFI!.unsafe_throwEither !== undefined) return

    window.__MONARCH_UNSAFE_FFI!.unsafe_throwEither = <a>(evalue: Either<string, a>): a => {
        const e = unLeft(evalue)
        if (e !== null) throw new Error(e)

        return unRight(evalue)!
    }
}

export function unsafe_registerAndGetVirtualDomNodeMaker<model, message, event extends Event, effects>(
    spec: Spec<model, message, event, effects>,
) {
    let mkNode = window.__MONARCH_UNSAFE_CUSTOM_ELEMENT_MAKERS_REGISTERY![spec.tagName]

    if (mkNode !== undefined) return mkNode

    mkNode = customNode(spec.tagName, mkCustomElement(spec))
    window.__MONARCH_UNSAFE_CUSTOM_ELEMENT_MAKERS_REGISTERY![spec.tagName] = mkNode

    return mkNode
}
