/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
 * Copyright  : (c) 2020 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { Patch } from 'monarch/Monarch/VirtualDom/Patch'
import { OutputHandlerTree } from 'monarch/Monarch/VirtualDom/OutputHandlerTree'
import { unsafe_organizeFacts, unsafe_applyFacts, OrganizedFacts, Facts, FactCategory } from 'monarch/Monarch/VirtualDom/Facts'
export type VirtualDomTree<message> = VirtualDomTree.Text | VirtualDomTree.Element<message>

export namespace VirtualDomTree {
    /**
     * Disjoint union tags for `VirtualDomTree` type
     */
    const enum Tag {
        Text,
        Element,
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

    // SUM TYPE: Element

    /**
     * `Element` tag
     *
     * Use it for pattern matching
     */
    export const Element = Tag.Element
    /**
     * `Element` type constructor
     */
    export interface Element<message> extends Tagged<typeof Element>, Parent<message> {
        ns?: NS
        tagName: TagName
        facts?: Facts
        organizedFacts?: OrganizedFacts
    }
    /**
     * Smart constructor for `Element` type with namespace
     */
    export function mkElementNS<message>(
        ns: NS,
        tagName: TagName,
        facts?: Facts,
        children?: ReadonlyArray<VirtualDomTree<message>>,
    ): Element<message> {
        return { tag: Element, ns, tagName, facts, children }
    }
    /**
     * Smart constructor for `Element` type without namespace
     */
    export function mkElement<message>(tagName: TagName, facts?: Facts, children?: ReadonlyArray<VirtualDomTree<message>>): Element<message> {
        return { tag: Element, tagName, facts, children }
    }

    // SUM TYPE: Tagger

    /**
     * TODO: tag Functor
     */
    export interface Tagger {}

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

    // INTERNAL

    interface Parent<message> {
        children?: ReadonlyArray<VirtualDomTree<message>>
    }
    type NS = 'http://www.w3.org/1999/xhtml' | 'http://www.w3.org/2000/svg' | 'http://www.w3.org/1998/Math/MathML'
}

type TagName = keyof HTMLElementTagNameMap

export const text = VirtualDomTree.mkText

// prettier-ignore
interface FNode {
  (tagName: TagName): (facts: Facts) => <message>(children: VirtualDomTree<message>[]) => VirtualDomTree<message>
}

// prettier-ignore
export const node: FNode = tagName => facts => children =>
  VirtualDomTree.mkElement(tagName, facts, children)

// prettier-ignore
interface Node_ {
  (tagName: TagName): <message>(children: VirtualDomTree<message>[]) => VirtualDomTree<message>
}

// prettier-ignore
export const node_: Node_ = tagName => children =>
  VirtualDomTree.mkElement(tagName, undefined, children)

// prettier-ignore
interface Node__ {
  <message>(tagName: TagName): VirtualDomTree<message>
}

// prettier-ignore
export const node__: Node__ = tagName =>
  VirtualDomTree.mkElement(tagName)

declare global {
    interface Node {
        monarch_outputHandlerNode?: OutputHandlerTree
    }
}

export function realize<message>(vNode: VirtualDomTree<message>, outputHandlerNode: OutputHandlerTree): Node {
    switch (vNode.tag) {
        case VirtualDomTree.Text:
            return realizeVirtualDomText(vNode)
    }

    const domNode = realizeVirtualDomElement(vNode)

    for (const child of vNode.children || []) {
        domNode.appendChild(realize(child, outputHandlerNode))
    }

    vNode.facts && unsafe_organizeFacts(vNode)

    vNode.organizedFacts && unsafe_applyFacts(domNode, vNode.organizedFacts)

    domNode.monarch_outputHandlerNode = outputHandlerNode

    return domNode
}

export function realizeVirtualDomText({ text }: VirtualDomTree.Text): Text {
    return document.createTextNode(text)
}

export function realizeVirtualDomElement<a>({ ns, tagName }: VirtualDomTree.Element<a>): Element {
    return ns ? document.createElementNS(ns, tagName) : document.createElement(tagName)
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
        case VirtualDomTree.Element:
            return unsafe_diffElement(x, <VirtualDomTree.Element<b>>y, patches)
    }
}

function unsafe_diffText<a, b>(x: VirtualDomTree.Text, y: VirtualDomTree.Text, patches: Patch[]): Diff<a, b> {
    if (x.text === y.text) return { patches }

    patches.push(Patch.mkText(y.text))

    return { patches }
}

function unsafe_diffElement<a, b>(x: VirtualDomTree.Element<a>, y: VirtualDomTree.Element<b>, patches: Patch[]): Diff<a, b> {
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
