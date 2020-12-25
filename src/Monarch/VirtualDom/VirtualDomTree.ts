/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { Patch } from 'monarch/Monarch/VirtualDom/Patch'
import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'
import { unsafe_organizeFacts, unsafe_applyFacts, OrganizedFacts, Facts, FactCategory } from 'monarch/Monarch/VirtualDom/Facts'

/**
 * Virtual DOM tree ADT
 */
export type VirtualDomTree<message> = VirtualDomTree.Text | VirtualDomTree.ElementNS<message> | VirtualDomTree.KeyedElementNS<message> | VirtualDomTree.Tagger<any, message>

export namespace VirtualDomTree {
    /**
     * Disjoint union tags for `VirtualDomTree` type
     */
    const enum Tag {
        Text,
        ElementNS,
        KeyedElementNS,
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
    /**
     * Smart constructor for `ElementNS` type with namespace
     */
    export function mkElementNS<message>(
        ns: NS | undefined,
        tagName: TagName,
        facts?: Facts,
        children?: ReadonlyArray<VirtualDomTree<message>>,
    ): ElementNS<message> {
        return { tag: ElementNS, ns, tagName, facts, children }
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
    export interface KeyedElementNS<message> extends Omit<ElementNS<message>, 'tag'>, Tagged<typeof KeyedElementNS> { }
    /**
     * Smart constructor for `KeyedElementNS` type with namespace
     */
    export function mkKeyedElementNS<message>(
        ns: NS | undefined,
        tagName: TagName,
        facts?: Facts,
        children?: ReadonlyArray<VirtualDomTree<message>>,
    ): KeyedElementNS<message> {
        return { tag: KeyedElementNS, ns, tagName, facts, children }
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

    // SUM TYPE: Async

    /**
     * TODO: subscribe to asynchronous virtual dom tree
     */
    export interface Async { }

    // SUM TYPE: Suspense

    /**
     * TODO: catch async nodes fallback
     */
    export interface Suspense { }

    // SUM TYPE: Thunk

    /**
     * TODO: evaluate the given thunk on reference change
     */
    export interface Thunk { }

    // SUM TYPE: Fragment

    /**
     * TODO: render subtrees as children of parent node
     */
    export interface Fragment { }

    // SUM TYPE: Offscreen

    /**
     * TODO: evaluate subtree on browsers' idle periods
     */
    export interface Offscreen { }

    // INTERNAL

    interface Parent<message> {
        children?: ReadonlyArray<VirtualDomTree<message>>
    }
}

type TagName = keyof HTMLElementTagNameMap
type NS = 'http://www.w3.org/1999/xhtml' | 'http://www.w3.org/2000/svg' | 'http://www.w3.org/1998/Math/MathML'

// prettier-ignore
interface FMapVirtualDomTree {
    <a, b>(f: (a: a) => b): (vNode: VirtualDomTree<a>) => VirtualDomTree<b>
}

// prettier-ignore
export const fmapVirtualDomTree: FMapVirtualDomTree = f => vNode => VirtualDomTree.mkTagger(f, vNode)

export const text = VirtualDomTree.mkText

// prettier-ignore
interface ElementNS {
    (ns: NS): (tagName: TagName) => (facts: Facts) => <message>(children: VirtualDomTree<message>[]) => VirtualDomTree<message>
}

// prettier-ignore
interface KeyedElementNS {
    (ns: NS): (tagName: TagName) => (facts: Facts) => <message>(children: VirtualDomTree<message>[]) => VirtualDomTree<message>
}

// prettier-ignore
export const elementNS: ElementNS | KeyedElementNS = ns => tagName => facts => children => {
    if (children.length > 0 && (children[0].tag === VirtualDomTree.ElementNS || children[0].tag === VirtualDomTree.KeyedElementNS) && children[0].facts?.key) {
        return VirtualDomTree.mkKeyedElementNS(ns, tagName, facts, children)
    }

    return VirtualDomTree.mkElementNS(ns, tagName, facts, children)
}

// prettier-ignore
interface ElementNS_ {
    (ns?: NS): (tagName: TagName) => <message>(children: VirtualDomTree<message>[]) => VirtualDomTree<message>
}

// prettier-ignore
export const elementNS_: ElementNS_ = ns => tagName => children =>
    VirtualDomTree.mkElementNS(ns, tagName, undefined, children)

// prettier-ignore
interface ElementNS__ {
    (ns?: NS): <message>(tagName: TagName) => VirtualDomTree<message>
}

// prettier-ignore
export const elementNS__: ElementNS__ = ns => tagName =>
    VirtualDomTree.mkElementNS(ns, tagName)

declare global {
    interface Node {
        monarch_outputHandlers?: OutputHandlersList
    }
}

export function realize<message>(vNode: VirtualDomTree<message>, outputHandlers: OutputHandlersList): Node {
    switch (vNode.tag) {
        case VirtualDomTree.Text:
            return realizeVirtualDomText(vNode)
        case VirtualDomTree.Tagger:
            return realizeVirtualDomTagger(vNode, outputHandlers)
    }

    const domNode = realizeVirtualDomElementNS(vNode)

    for (const child of vNode.children || []) {
        domNode.appendChild(realize(child, outputHandlers))
    }

    vNode.facts && unsafe_organizeFacts(vNode)

    vNode.organizedFacts && unsafe_applyFacts(domNode, vNode.organizedFacts)

    domNode.monarch_outputHandlers = outputHandlers

    return domNode
}

export function realizeVirtualDomText({ text }: VirtualDomTree.Text): Text {
    return document.createTextNode(text)
}

export function realizeVirtualDomTagger<a, b>(tagger: VirtualDomTree.Tagger<a, b>, outputHandlers: OutputHandlersList): Node {
    unsafe_flattenVirtualDomTaggers(tagger)

    return realize(tagger.vNode, { value: tagger.f, next: outputHandlers })
}

export function realizeVirtualDomElementNS<a>({ ns, tagName }: VirtualDomTree.ElementNS<a> | VirtualDomTree.KeyedElementNS<a>): Element {
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
            return unsafe_diffKeyedElementNS(x, <VirtualDomTree.KeyedElementNS<b>>y, patches)
        case VirtualDomTree.Tagger:
            return unsafe_diffTagger(x, <VirtualDomTree.Tagger<any, any>>y, patches)
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

function unsafe_diffTagger<a, b, c, d>(x: VirtualDomTree.Tagger<a, b>, y: VirtualDomTree.Tagger<c, d>, patches: Patch[]): Diff<b, d> {
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

function unsafe_diffElementNS<a, b>(x: VirtualDomTree.ElementNS<a>, y: VirtualDomTree.ElementNS<b>, patches: Patch[]): Diff<a, b> {
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

    const xChildrenLength = x.children?.length || 0
    const yChildrenLength = y.children?.length || 0

    if (xChildrenLength > yChildrenLength) {
        patches.push(Patch.mkRemoveFromEnd(xChildrenLength - yChildrenLength))
    } else if (xChildrenLength < yChildrenLength) {
        patches.push(Patch.mkAppend(y.children!, xChildrenLength))
    }

    const minChildrenLength = Math.min(xChildrenLength, yChildrenLength)

    const downstreamNodes: DownstreamNode<a, b>[] = []

    for (let i = 0; i < minChildrenLength; i++) {
        downstreamNodes.push({ x: x.children![i], y: y.children![i] })
    }

    return { patches, downstreamNodes }
}

function unsafe_diffElementNSChildren<a, b>(x: VirtualDomTree.ElementNS<a>, y: VirtualDomTree.ElementNS<b>, patches: Patch[]): Diff<a, b> {

}

function unsafe_diffKeyedElementNSChildren<>() {

}

function unsafe_diffKeyedElementNS<a, b>(x: VirtualDomTree.KeyedElementNS<a>, y: VirtualDomTree.KeyedElementNS<b>, patches: Patch[]): Diff<a, b> {
    return { patches }
}

function diffKeyedChildren<a, b>(xParent: VirtualDomTree.KeyedElementNS<a>, yParent: VirtualDomTree.KeyedElementNS<b>) {
    // const xChildren = xParent.children!
    // const yChildren = yParent.children!
    // const xChildrenLength = xChildren.length
    // const yChildrenLength = yChildren.length

    // const downstreamNodes: DownstreamNode<a, b>[] = []

    // let xIndex = 0
    // let yIndex = 0

    // while (xIndex < xChildrenLength && yIndex < yChildrenLength) {
    //     const x = xChildren[xIndex] as VirtualDomTree.ElementNS<a>
    //     const y = yChildren[yIndex] as VirtualDomTree.ElementNS<b>
    //     const xKey = x.key
    //     const yKey = y.key

    //     if (xKey === yKey) {
    //         downstreamNodes.push({ x, y })
    //         xIndex++
    //         yIndex++
    //     }

    //     const xNext = xChildren[xIndex + 1] as VirtualDomTree.ElementNS<a>
    //     const yNext = yChildren[yIndex + 1] as VirtualDomTree.ElementNS<b>

    //     const oldMatch = xNext ? yKey === xNext.key : false
    //     const newMatch = yNext ? xKey === yNext.key : false

    //     if (newMatch && oldMatch) {
    //         downstreamNodes.push({ x, y })

    //     }
    // }
}

type SumWithSubTypes<T extends {}> = T | T[keyof T]

function diffFacts<a extends SumWithSubTypes<OrganizedFacts>>(x: a | undefined, y: a | undefined): a | undefined {
    let diff: a

    for (const xKey in x) {
        if (xKey in FactCategory) {
            const subDiff = diffFacts(x![xKey], y && y![xKey])

            if (subDiff) {
                diff = diff! || {}
                diff![xKey] = subDiff
            }

            continue
        }

        if (!(y && xKey in y)) {
            diff = diff! || {}
            diff![xKey] = <any>undefined

            continue
        }

        var xValue = x![xKey]
        var yValue = y![xKey]

        if (xValue === yValue && xKey !== 'value' && xKey !== 'checked') {
            continue
        }

        diff = diff! || {}
        diff![xKey] = yValue
    }

    for (const yKey in y) {
        if (x && yKey in x) continue

        diff = diff! || {}
        diff![yKey] = y![yKey]
    }

    return diff!
}
