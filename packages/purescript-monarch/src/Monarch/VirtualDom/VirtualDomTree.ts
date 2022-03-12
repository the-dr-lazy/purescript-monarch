/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { VirtualDomTree, NS, TagName } from '@purescript-monarch/core/src/VirtualDom/VirtualDomTree'
import { Facts } from '@purescript-monarch/core/src/VirtualDom/Facts'

// prettier-ignore
interface FMapVirtualDomTree {
    <a, b>(f: (a: a) => b): (vNode: VirtualDomTree<a>) => VirtualDomTree<b>
}

// prettier-ignore
export const fmapVirtualDomTree: FMapVirtualDomTree = f => vNode => {
    let tagger: VirtualDomTree<any> = VirtualDomTree.mkTagger(f, vNode.tag === VirtualDomTree.Keyed ? vNode.vNode : vNode)

    if (vNode.tag === VirtualDomTree.Keyed) {
        tagger = VirtualDomTree.mkKeyed(vNode.key, tagger)
    }

    return tagger
}

export const node = <message>(spec: { ns: NS; tagName: TagName; facts: Facts }): VirtualDomTree<message> =>
    VirtualDomTree.mkElementNS(spec.ns, spec.tagName, spec.facts, spec.facts.children)

export const leaf = <message>(spec: { ns: NS; tagName: TagName; facts: Facts }): VirtualDomTree<message> =>
    VirtualDomTree.mkElementNS(spec.ns, spec.tagName, spec.facts, undefined)

export const text = VirtualDomTree.mkText

// prettier-ignore
interface Keyed {
    (key: any): <message>(vNode: VirtualDomTree<message>) => VirtualDomTree<message>
}

// prettier-ignore
export const keyed: Keyed = key => vNode => VirtualDomTree.mkKeyed(key, vNode)
