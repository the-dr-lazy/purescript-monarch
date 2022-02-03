/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { Patch } from 'monarch/Monarch/VirtualDom/Patch'
import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'
import {
    unsafe_organizeFacts,
    unsafe_applyFacts,
    OrganizedFacts,
    Facts,
    FactCategory,
    keyPropertyName,
} from 'monarch/Monarch/VirtualDom/Facts'
import { ReorderHistory } from 'monarch/Monarch/VirtualDom/ReorderHistory'

/**
 * Virtual DOM tree ADT
 */
export type VirtualDomTree<message> =
    | VirtualDomTree.Text
    | VirtualDomTree.ElementNS<message>
    | VirtualDomTree.KeyedElementNS<message>
    | VirtualDomTree.Keyed<VirtualDomTree<message>>
    | VirtualDomTree.Tagger<any, message>

export namespace VirtualDomTree {
    /**
     * Disjoint union tags for `VirtualDomTree` type
     */
    const enum Tag {
        Text,
        ElementNS,
        KeyedElementNS,
        Keyed,
        Tagger,
    }

    // SUM TYPE: Text

    /**
     * `Text` tag
     *
     * Use it for pattern matching.
     */
    export const Text = Tag.Text
    /**
     * `Text` type constructor
     */
    export interface Text extends Tagged<typeof Text> {
        text: string
    }
    /**
     * Smart data constructor for `Text` type
     */
    export function mkText(text: string): Text {
        return { tag: Text, text }
    }

    // SUM TYPE: ElementNS

    /**
     * `ElementNS` tag
     *
     * Use it for pattern matching
     */
    export const ElementNS = Tag.ElementNS
    /**
     * `ElementNS` type constructor
     */
    export interface ElementNS<message> extends Tagged<typeof ElementNS>, Parent<message> {
        ns?: NS
        tagName: TagName
        facts?: Facts
        organizedFacts?: OrganizedFacts
    }

    // SUM TYPE: KeyedElementNS

    /**
     * `KeyedElementNS` tag
     *
     * Use it for pattern matching
     */
    export const KeyedElementNS = Tag.KeyedElementNS
    /**
     * `KeyedElementNS` type constructor
     */
    export interface KeyedElementNS<message>
        extends Omit<ElementNS<message>, 'tag' | 'children'>,
            Tagged<typeof KeyedElementNS> {
        children?: ReadonlyArray<VirtualDomTree.Keyed<VirtualDomTree<message>>>
    }

    // SUM TYPE: Keyed

    /**
     * `Keyed` tag
     *
     * Use it for pattern matching
     */
    export const Keyed = Tag.Keyed
    /**
     * `Keyed` type constructor
     */
    export interface Keyed<vNode extends VirtualDomTree<any>> extends Tagged<typeof Keyed> {
        key: any
        vNode: vNode
    }
    /**
     * Smart constructor for `Keyed` type with namespace
     */
    export function mkKeyed<vNode extends VirtualDomTree<any>>(key: any, vNode: vNode): Keyed<vNode> {
        return { tag: Keyed, key, vNode }
    }

    // SUM TYPE: Tagger

    export const Tagger = Tag.Tagger
    /**
     * `Tagger` type constructor
     */
    export interface Tagger<a, b> extends Tagged<typeof Tagger> {
        f: OutputHandlersList.Cons['value']
        vNode: VirtualDomTree<a>
    }
    export function mkTagger<a, b>(f: (a: a) => b, vNode: VirtualDomTree<a>): Tagger<a, b> {
        return { tag: Tagger, f, vNode }
    }

    /**
     * Smart constructor for `ElementNS` and `KeyedElementNS` types
     */
    export function mkElementNS<message>(
        ns: NS | undefined,
        tagName: TagName,
        facts?: Facts,
        children?: ReadonlyArray<VirtualDomTree.Keyed<VirtualDomTree<message>>>,
    ): SumWithKeyed<VirtualDomTree.KeyedElementNS<message>>
    export function mkElementNS<message>(
        ns: NS | undefined,
        tagName: TagName,
        facts?: Facts,
        children?: ReadonlyArray<VirtualDomTree<message>>,
    ): SumWithKeyed<VirtualDomTree.ElementNS<message>>
    export function mkElementNS<message>(
        ns: NS | undefined,
        tagName: TagName,
        facts?: Facts,
        children?: ReadonlyArray<VirtualDomTree<message>>,
    ) {
        const tag =
            children && children[0]?.tag === VirtualDomTree.Keyed
                ? VirtualDomTree.KeyedElementNS
                : VirtualDomTree.ElementNS
        let vNode: VirtualDomTree<message> = {
            tag,
            ns,
            tagName,
            facts,
            children: <any>children,
        }

        if (facts && keyPropertyName in facts) {
            vNode = VirtualDomTree.mkKeyed(facts[keyPropertyName], vNode)
        }

        return vNode
    }

    // SUM TYPE: Async

    /**
     * TODO: subscribe to asynchronous virtual dom tree
     */
    export interface Async {}

    // SUM TYPE: Suspense

    /**
     * TODO: catch async nodes fallback
     */
    export interface Suspense {}

    // SUM TYPE: Thunk

    /**
     * TODO: evaluate the given thunk on reference change
     */
    export interface Thunk {}

    // SUM TYPE: Fragment

    /**
     * TODO: render subtrees as children of parent node
     */
    export interface Fragment {}

    // SUM TYPE: Offscreen

    /**
     * TODO: evaluate subtree on browsers' idle periods
     */
    export interface Offscreen {}

    export type Node = (
        facts: Facts,
    ) => <message>(children: ReadonlyArray<VirtualDomTree<message>>) => VirtualDomTree<message>
    export type Leaf = <message>(facts: Facts) => VirtualDomTree<message>

    // INTERNAL

    interface Parent<message> {
        children?: ReadonlyArray<VirtualDomTree<message>>
    }

    type SumWithKeyed<vNode extends VirtualDomTree<any>> = vNode | VirtualDomTree.Keyed<vNode>
}

export type TagName = keyof HTMLElementTagNameMap | string
export type NS = 'http://www.w3.org/1999/xhtml' | 'http://www.w3.org/2000/svg' | 'http://www.w3.org/1998/Math/MathML'

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

declare global {
    interface Node {
        monarch_outputHandlers: OutputHandlersList
    }
}

export function realize<message>(vNode: VirtualDomTree<message>, outputHandlers: OutputHandlersList): Node {
    switch (vNode.tag) {
        case VirtualDomTree.Text:
            const text = realizeVirtualDomText(vNode)
            text.monarch_outputHandlers = outputHandlers
            return text
        case VirtualDomTree.Tagger:
            return realizeVirtualDomTagger(vNode, outputHandlers)
        case VirtualDomTree.Keyed:
            return realize(vNode.vNode, outputHandlers)
    }

    const domNode = realizeVirtualDomElementNS(vNode)

    for (let child of vNode.children ?? []) {
        const childNode = realize(child, outputHandlers)

        // TODO: use document fragment to reduce DOM changes.
        domNode.appendChild(childNode)
    }

    vNode.facts && unsafe_organizeFacts(vNode)
    vNode.organizedFacts && unsafe_applyFacts(domNode, vNode.organizedFacts)

    domNode.monarch_outputHandlers = outputHandlers

    return domNode
}

export function realizeVirtualDomText({ text }: VirtualDomTree.Text): Text {
    return document.createTextNode(text)
}

export function realizeVirtualDomTagger<a, b>(
    tagger: VirtualDomTree.Tagger<a, b>,
    outputHandlers: OutputHandlersList,
): Node {
    unsafe_flattenVirtualDomTaggers(tagger)

    return realize(tagger.vNode, { value: tagger.f, next: outputHandlers })
}

export function realizeVirtualDomElementNS<a>({
    ns,
    tagName,
}: VirtualDomTree.ElementNS<a> | VirtualDomTree.KeyedElementNS<a>): Element {
    return ns ? document.createElementNS(ns, tagName) : document.createElement(tagName)
}

function unsafe_flattenVirtualDomTaggers<a, b>(tagger: VirtualDomTree.Tagger<a, b>) {
    let fs: OutputHandlersList.Cons['value'] = tagger.f
    let subVNode: VirtualDomTree<a> = tagger.vNode

    while (subVNode.tag === VirtualDomTree.Tagger) {
        typeof fs === 'function' && (fs = [fs])
        typeof subVNode.f === 'function' ? fs.push(subVNode.f) : fs.concat(subVNode.f)

        subVNode = subVNode.vNode
    }

    tagger.f = fs
    tagger.vNode = subVNode
}

export type DownstreamNode<a, b> = {
    x: VirtualDomTree<a>
    y: VirtualDomTree<b>
    ix?: number
}

export type Diff<a, b> = {
    patches: Patch[]
    downstreamNodes?: DownstreamNode<a, b>[]
}

export function diff<a, b>(x: VirtualDomTree<a>, y: VirtualDomTree<b>): Diff<a, b> {
    const patches: Patch[] = []

    if (x === y) {
        return { patches }
    }

    if (x.tag !== y.tag) {
        patches.push(Patch.mkRedraw(y))

        return { patches }
    }

    switch (x.tag) {
        case VirtualDomTree.Text:
            return unsafe_diffText(x, <VirtualDomTree.Text>y, patches)
        case VirtualDomTree.ElementNS:
            return unsafe_diffElementNS(x, <VirtualDomTree.ElementNS<b>>y, patches)
        case VirtualDomTree.KeyedElementNS:
            return unsafe_diffElementNS(x, <VirtualDomTree.KeyedElementNS<b>>y, patches)
        case VirtualDomTree.Tagger:
            return unsafe_diffTagger(x, <VirtualDomTree.Tagger<any, any>>y, patches)
        case VirtualDomTree.Keyed:
            return diff(x.vNode, (<VirtualDomTree.Keyed<VirtualDomTree<b>>>y).vNode)
    }
}

function unsafe_diffText<a, b>(x: VirtualDomTree.Text, y: VirtualDomTree.Text, patches: Patch[]): Diff<a, b> {
    if (x.text === y.text) return { patches }

    patches.push(Patch.mkText(y.text))

    return { patches }
}

function pairwiseRefEq<a>(xs: readonly a[], ys: readonly a[]): boolean {
    for (var i = 0; i < xs.length; i++) {
        if (xs[i] !== ys[i]) return false
    }

    return true
}

function unsafe_diffTagger<a, b, c, d>(
    x: VirtualDomTree.Tagger<a, b>,
    y: VirtualDomTree.Tagger<c, d>,
    patches: Patch[],
): Diff<b, d> {
    unsafe_flattenVirtualDomTaggers(y)

    const nested = typeof x.f !== 'function' || typeof y.f !== 'function'

    if (nested && x.f.length !== y.f.length) {
        patches.push(Patch.mkRedraw(y))

        return { patches }
    }

    if (nested ? !pairwiseRefEq(<Function[]>x.f, <Function[]>y.f) : x.f !== y.f) {
        patches.push(Patch.mkTagger(y.f))
    }

    return { patches, downstreamNodes: [{ x: x.vNode, y: y.vNode }] }
}

function unsafe_diffElementNS<
    a,
    x extends VirtualDomTree.ElementNS<a> | VirtualDomTree.KeyedElementNS<a>,
    b,
    y extends x extends VirtualDomTree.ElementNS<a> ? VirtualDomTree.ElementNS<b> : VirtualDomTree.KeyedElementNS<b>,
>(x: x, y: y, patches: Patch[]): Diff<a, b> {
    if (x.ns !== y.ns || x.tagName !== y.tagName) {
        patches.push(Patch.mkRedraw(y))
        return { patches }
    }

    x.facts && unsafe_organizeFacts(x)
    y.facts && unsafe_organizeFacts(y)

    if (x.organizedFacts || y.organizedFacts) {
        const diff = diffFacts(x.organizedFacts, y.organizedFacts)

        diff && patches.push(Patch.mkFacts(diff))
    }

    const unsafe_diffChildren: Function =
        x.tag === VirtualDomTree.ElementNS ? unsafe_diffElementNSChildren : unsafe_diffKeyedElementNSChildren

    const downstreamNodes = unsafe_diffChildren(x.children, y.children, patches)

    return { patches, downstreamNodes }
}

function unsafe_diffElementNSChildren<a, b>(
    xs: ReadonlyArray<VirtualDomTree<a>> | undefined,
    ys: ReadonlyArray<VirtualDomTree<b>> | undefined,
    patches: Patch[],
): DownstreamNode<a, b>[] {
    const xsLength = xs?.length ?? 0
    const ysLength = ys?.length ?? 0

    if (xsLength > ysLength) {
        patches.push(Patch.mkRemoveFromEnd(xsLength - ysLength))
    } else if (xsLength < ysLength) {
        patches.push(Patch.mkAppend(ys!, xsLength))
    }

    const minChildrenLength = Math.min(xsLength, ysLength)

    const downstreamNodes: DownstreamNode<a, b>[] = []

    for (let ix = 0; ix < minChildrenLength; ix++) {
        downstreamNodes.push({ x: xs![ix], y: ys![ix], ix })
    }

    return downstreamNodes
}

function unsafe_diffKeyedElementNSChildren<a, b>(
    xs: ReadonlyArray<VirtualDomTree.Keyed<VirtualDomTree<a>>> | undefined,
    ys: ReadonlyArray<VirtualDomTree.Keyed<VirtualDomTree<b>>> | undefined,
    patches: Patch[],
): DownstreamNode<a, b>[] {
    const history: ReorderHistory<a, b> = ReorderHistory.mk()

    const xsLength = xs?.length ?? 0
    const ysLength = ys?.length ?? 0

    let xIx = 0
    let yIx = 0

    const downstreamNodes: DownstreamNode<a, b>[] = []

    while (xIx < xsLength && yIx < ysLength) {
        const x = xs![xIx]
        const y = ys![yIx]

        const xKey = x.key
        const yKey = y.key

        /**
         * x->y
         * ----
         * A  A
         * -  -
         *
         * Cross match.
         */
        if (xKey == yKey) {
            downstreamNodes.push({ x, y, ix: yIx })

            xIx += 1
            yIx += 1

            continue
        }

        const nextX = xs![xIx + 1]
        const nextY = ys![yIx + 1]

        const nextXKey = nextX?.key
        const nextYKey = nextY?.key

        const upsideObliqueMatch = nextXKey === yKey
        const downsideObliqueMatch = nextYKey === xKey

        /**
         * x->y
         * ----
         * A  B
         * B  A
         *
         * Children has been swaped.
         *
         * - Push `A` to the downstream diffs.
         * - Move `B` before the `A`.
         */
        if (upsideObliqueMatch && downsideObliqueMatch) {
            downstreamNodes.push({ x, y: nextY, ix: yIx + 1 })

            ReorderHistory.unsafe_move(yKey, nextX, xIx + 1, y, yIx, downstreamNodes, history)

            xIx += 2
            yIx += 2

            continue
        }

        /**
         * x->y
         * ----
         * A  B
         * C  A
         *
         * Downside oblique match.
         *
         * - Push the `A` to the downstream diffs.
         * - Candidate `B` for insertion as its in the new virtual DOM tree.
         */
        if (downsideObliqueMatch) {
            downstreamNodes.push({ x, y: nextY, ix: yIx + 1 })

            ReorderHistory.unsafe_insert(yKey, y, yIx, downstreamNodes, history)

            xIx += 1
            yIx += 2

            continue
        }

        /**
         * x->y
         * ----
         * A  B
         * B  C
         *
         * Upside oblique match.
         *
         * - Push the `B` to the downstream diffs.
         * - Candidate `A` for removing as its in the old virtual DOM tree.
         */
        if (upsideObliqueMatch) {
            downstreamNodes.push({ x: nextX, y, ix: yIx })

            ReorderHistory.unsafe_remove(xKey, x, xIx, downstreamNodes, history)

            xIx += 2
            yIx += 1

            continue
        }

        /**
         * x->y
         * ----
         * A  B
         * C  C
         *
         * Next horizontal match.
         *
         * - Push the `C` to the downstream diffs.
         * - Candidate `A` for removing as its in the old virtual DOM tree.
         * - Candidate `B` for insertion as its in the new virtual DOM tree.
         */
        if (nextX && nextXKey === nextYKey) {
            downstreamNodes.push({ x: nextX, y: nextY, ix: yIx + 1 })

            ReorderHistory.unsafe_remove(xKey, x, xIx, downstreamNodes, history)
            ReorderHistory.unsafe_insert(yKey, y, yIx, downstreamNodes, history)

            xIx += 2
            yIx += 2

            continue
        }

        break
    }

    // Consume rest of old children and candidate them for removing.
    while (xIx < xsLength) {
        const x = xs![xIx]
        const xKey = x.key

        ReorderHistory.unsafe_remove(xKey, x, xIx, downstreamNodes, history)

        xIx += 1
    }

    // Consume rest of new children and candidate them for inserting.
    while (yIx < ysLength) {
        const y = ys![yIx]
        const yKey = y.key

        ReorderHistory.unsafe_insert(yKey, y, yIx, downstreamNodes, history, true)

        yIx += 1
    }

    patches.push(Patch.mkReorder(history))

    return downstreamNodes
}

type SumWithSubTypes<T extends {}> = T | T[keyof T]

function diffFacts<a extends SumWithSubTypes<OrganizedFacts>>(x: a | undefined, y: a | undefined): a | undefined {
    let diff: a

    for (const xKey in x) {
        if (xKey in FactCategory) {
            const subDiff = diffFacts(x![xKey], y && y![xKey])

            if (subDiff) {
                diff = diff! ?? {}
                diff![xKey] = subDiff
            }

            continue
        }

        if (!(y && xKey in y)) {
            diff = diff! ?? {}
            diff![xKey] = <any>undefined

            continue
        }

        var xValue = x![xKey]
        var yValue = y![xKey]

        if (xValue === yValue && xKey !== 'value' && xKey !== 'checked') {
            continue
        }

        diff = diff! ?? {}
        diff![xKey] = yValue
    }

    for (const yKey in y) {
        if (x && yKey in x) continue

        diff = diff! ?? {}
        diff![yKey] = y![yKey]
    }

    return diff!
}
