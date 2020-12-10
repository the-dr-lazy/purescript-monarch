/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { Patch, unsafe_applyPatch } from 'monarch/Monarch/VirtualDom/Patch'
export type PatchTree = PatchTree.Root | PatchTree.Node

export namespace PatchTree {
    // SUM TYPE: Root

    /**
     * `Root` type constructor
     */
    export interface Root {
        patches?: Patch[]
        children?: PatchTree[]
    }

    // SUM TYPE: Node

    /**
     * `Node` type constructor
     */
    export interface Node {
        address: Address
        patches?: Patch[]
        children?: PatchTree[]
    }

    export type Address = number[]
}

export function unsafe_uncurried_applyPatchTree(rootDomNode: Node, rootPatchNode: PatchTree) {
    let domNode = rootDomNode

    if ('address' in rootPatchNode) {
        for (const i of rootPatchNode.address) {
            domNode = domNode.childNodes[i]
        }
    }

    if (rootPatchNode.patches) {
        for (const patch of rootPatchNode.patches!) {
            unsafe_applyPatch(domNode, patch)
        }
    }

    if (rootPatchNode.children) {
        for (const patchNode of rootPatchNode.children!) {
            unsafe_uncurried_applyPatchTree(domNode, patchNode)
        }
    }
}
