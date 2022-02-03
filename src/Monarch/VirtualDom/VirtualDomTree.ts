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
    unsafe_applyFacts,
    OrganizedFacts,
    Facts,
    FactCategory,
    keyPropertyName,
    organizeFacts,
} from 'monarch/Monarch/VirtualDom/Facts'
import * as List from 'monarch/Monarch/Data/List'
import * as LazyMorphism from 'monarch/Monarch/Data/LazyMorphism'
import * as Children from 'monarch/Monarch/VirtualDom/VirtualDomTree/Children'

/**
 * Virtual DOM tree ADT
 */
export type VirtualDomTree<message> =
    | VirtualDomTree.Text
    | VirtualDomTree.ElementNS<message>
    | VirtualDomTree.Keyed<VirtualDomTree<message>>
    | VirtualDomTree.Tagger<any, message>
    | VirtualDomTree.CustomHtmlElement<message>

export namespace VirtualDomTree {
    /**
     * Disjoint union tags for `VirtualDomTree` type
     *
     * Note: Don't use the 3x for any other tagged unions.
     */
    export enum Tag {
        Text = 30,
        ElementNS = 31,
        Keyed = 32,
        Tagger = 33,
        CustomHtmlElement = 34,
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
    export interface ElementNS<message> extends Tagged<typeof ElementNS> {
        ns?: NS
        tagName: TagName
        facts?: LazyMorphism.Type<Facts, OrganizedFacts>
        children?: LazyMorphism.Type<ReadonlyArray<VirtualDomTree<message>>, Children.Type<message>>
    }
    /**
     * Smart constructor for `ElementNS`
     */
    export function mkElementNS<message>(
        ns: NS | undefined,
        tagName: TagName,
        facts?: Facts,
        children?: ReadonlyArray<VirtualDomTree<message>>,
    ) {
        let vNode: VirtualDomTree.ElementNS<message> | VirtualDomTree.Keyed<VirtualDomTree.ElementNS<message>> = {
            tag: Tag.ElementNS,
            ns,
            tagName,
            facts: facts && LazyMorphism.mk(facts),
            children: children && LazyMorphism.mk(children),
        }

        if (facts && keyPropertyName in facts) {
            vNode = VirtualDomTree.mkKeyed(facts[keyPropertyName], vNode)
        }

        return vNode
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
    export interface Tagger<a, _b> extends Tagged<typeof Tagger> {
        f: OutputHandlersList.Cons['value']
        vNode: VirtualDomTree<a>
    }
    export function mkTagger<a, b>(f: (a: a) => b, vNode: VirtualDomTree<a>): Tagger<a, b> {
        return { tag: Tagger, f, vNode }
    }

    // SUM TYPE: CustomHtmlElement

    /**
     * `CustomHtmlElement` tag
     *
     * Use it for pattern matching
     */
    export const CustomHtmlElement = Tag.CustomHtmlElement
    /**
     * `CustomHtmlElement` type constructor
     */
    export interface CustomHtmlElement<message> extends Tagged<typeof CustomHtmlElement> {
        ns: undefined
        tagName: string
        ctor: CustomElementConstructor
        facts?: LazyMorphism.Type<Facts, OrganizedFacts>
        slots?: { [key: string]: VirtualDomTree<message> | ReadonlyArray<VirtualDomTree<message>> }
    }
    /**
     * Smart constructor for `CustomHtmlElement` type with namespace
     */
    export function mkCustomHtmlElement<message>(
        tagName: string,
        ctor: CustomElementConstructor,
        facts?: Facts,
        slots?: { [key: string]: VirtualDomTree<message> | ReadonlyArray<VirtualDomTree<message>> },
    ): CustomHtmlElement<message> {
        return {
            tag: CustomHtmlElement,
            ns: undefined,
            tagName,
            ctor,
            slots,
            facts: facts && LazyMorphism.mk(facts),
        }
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

export const node = <message>({
    ns,
    tagName,
    facts,
    children,
}: {
    ns: NS
    tagName: TagName
    facts: Facts
    children: ReadonlyArray<VirtualDomTree<message>>
}): VirtualDomTree<message> => VirtualDomTree.mkElementNS(ns, tagName, facts, children)

export const leaf = <message>({
    ns,
    tagName,
    facts,
}: {
    ns: NS
    tagName: TagName
    facts: Facts
}): VirtualDomTree<message> => VirtualDomTree.mkElementNS(ns, tagName, facts, undefined)

export const text = VirtualDomTree.mkText

// prettier-ignore
type Keyed = (key: any) => <message>(vNode: VirtualDomTree<message>) => VirtualDomTree<message>

export const keyed: Keyed = key => vNode => VirtualDomTree.mkKeyed(key, vNode)

// prettier-ignore
type CustomNode = (tagName: string, ctor: CustomElementConstructor) => (facts: Facts) => <message>(children: { [key: string]: VirtualDomTree<message> | ReadonlyArray<VirtualDomTree<message>> }) => VirtualDomTree<message>

export const customNode: CustomNode = (tagName, ctor) => facts => children =>
    VirtualDomTree.mkCustomHtmlElement(tagName, ctor, facts, children)

declare global {
    interface Node {
        __MONARCH_UNSAFE_OUTPUT_HANDLERS: OutputHandlersList
        __MONARCH_CHILD_NODE_BY_KEY_MAP: Map<unknown, DOM.Node>
        __MONARCH_SLOTS_CHILD_NODE_BY_KEY_MAP: { [key: string]: Map<unknown, DOM.Node> }
    }
}

export function realize<message>(vNode: VirtualDomTree<message>, outputHandlers: OutputHandlersList): DOM.Node {
    switch (vNode.tag) {
        case VirtualDomTree.Text:
            return realizeVirtualDomText(vNode, outputHandlers)
        case VirtualDomTree.Tagger:
            return realizeVirtualDomTagger(vNode, outputHandlers)
        case VirtualDomTree.Keyed:
            return realize(vNode.vNode, outputHandlers)
    }

    const domNode = realizeVirtualDomElementNS(vNode)

    // Note: We are not using document fragment because the DOM node
    // has not been inserted to the DOM tree. So it won't bring us any performance.
    if (vNode.tag === VirtualDomTree.CustomHtmlElement) {
        for (let name in vNode.slots) {
            const children = parseChildren(vNode.slots[name]).value
            const length = children.length

            for (let ix = 0; ix < length; ix++) {
                const childDomElement = <Element>realize(children[ix], outputHandlers)
                childDomElement.slot = name
                domNode.appendChild(childDomElement)
            }
        }
    } else {
        const children = vNode.children && LazyMorphism.unsafe_evaluate(vNode.children, parseChildren)

        children && Children.unsafe_realize(children, outputHandlers, domNode.appendChild)
    }

    const facts = vNode.facts && LazyMorphism.unsafe_evaluate(vNode.facts, organizeFacts(vNode.tagName))
    facts && unsafe_applyFacts(domNode, facts)

    domNode.__MONARCH_UNSAFE_OUTPUT_HANDLERS = outputHandlers

    return domNode
}

export function realizeVirtualDomText({ text }: VirtualDomTree.Text, outputHandlers: OutputHandlersList): Text {
    const node = document.createTextNode(text)

    node.__MONARCH_UNSAFE_OUTPUT_HANDLERS = outputHandlers

    return node
}

export function realizeVirtualDomTagger<a, b>(
    tagger: VirtualDomTree.Tagger<a, b>,
    outputHandlers: OutputHandlersList,
): Node {
    unsafe_flattenVirtualDomTaggers(tagger)

    return realize(tagger.vNode, { value: tagger.f, next: outputHandlers })
}

export function realizeVirtualDomElementNS<message>(
    vNode: VirtualDomTree.ElementNS<message> | VirtualDomTree.CustomHtmlElement<message>,
): Element {
    const { tagName, ns } = vNode

    if (vNode.tag === VirtualDomTree.CustomHtmlElement && window.customElements.get(vNode.tagName) === undefined)
        window.customElements.define(vNode.tagName, vNode.ctor)

    return ns !== undefined ? document.createElementNS(ns, tagName) : document.createElement(tagName)
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

export interface DownstreamNode<a, b> {
    x: VirtualDomTree<a>
    y: VirtualDomTree<b>
    targetDomNode: DOM.Node
}

export interface DiffResult<a, b> {
    downstreamNodes: List.Type<DownstreamNode<a, b>>
    patches: List.Type<Patch>
}

export function diff<a, b>(
    x: VirtualDomTree<a>,
    y: VirtualDomTree<b>,
    targetDomNode: DOM.Node,
    patches: List.Type<Patch>,
    downstreamNodes: List.Type<DownstreamNode<a, b>>,
): DiffResult<a, b> {
    if (x === y) return { patches, downstreamNodes }

    if (x.tag !== y.tag) return { patches: List.mkCons(Patch.mkRedraw(targetDomNode, y), patches), downstreamNodes }

    switch (x.tag) {
        case VirtualDomTree.Text:
            return diffText(x, <typeof x>y, <DOM.Text>targetDomNode, patches, downstreamNodes)
        case VirtualDomTree.ElementNS:
            return diffElementNS(x, <typeof x>y, <DOM.Element>targetDomNode, patches, downstreamNodes)
        case VirtualDomTree.CustomHtmlElement:
            return undefined
        case VirtualDomTree.Tagger:
            return diffTagger(x, <typeof x>y, targetDomNode, patches, downstreamNodes)
        case VirtualDomTree.Keyed:
            return diff(x.vNode, (<typeof x>y).vNode, targetDomNode, patches, downstreamNodes)
    }
}

function diffText<a, b>(
    x: VirtualDomTree.Text,
    y: VirtualDomTree.Text,
    targetTextNode: DOM.Text,
    patches: List.Type<Patch>,
    downstreamNodes: List.Type<DownstreamNode<a, b>>,
): DiffResult<a, b> {
    if (x.text === y.text) return { patches, downstreamNodes }

    return { patches: List.mkCons(Patch.mkText(targetTextNode, y.text), patches), downstreamNodes }
}

function pairwiseRefEq<a>(xs: ReadonlyArray<a>, ys: ReadonlyArray<a>): boolean {
    for (var i = 0; i < xs.length; i++) {
        if (xs[i] !== ys[i]) return false
    }

    return true
}

function diffTagger<a, b, c, d>(
    x: VirtualDomTree.Tagger<a, b>,
    y: VirtualDomTree.Tagger<c, d>,
    targetDomNode: DOM.Node,
    patches: List.Type<Patch>,
    downstreamNodes: List.Type<DownstreamNode<a, b>>,
): DiffResult<b, d> {
    unsafe_flattenVirtualDomTaggers(y)

    const nested = typeof x.f !== 'function' || typeof y.f !== 'function'

    if (nested && x.f.length !== y.f.length) {
        return { patches: List.mkCons(Patch.mkRedraw(targetDomNode, y), patches), downstreamNodes }
    }

    if (nested ? !pairwiseRefEq(<Function[]>x.f, <Function[]>y.f) : x.f !== y.f) {
        patches = List.mkCons(Patch.mkTagger(targetDomNode, y.f), patches)
    }

    return {
        patches,
        downstreamNodes: List.mkCons({ x: x.vNode, y: y.vNode, targetDomNode: targetDomNode }, downstreamNodes),
    }
}

function diffElementNS<a, b>(
    x: VirtualDomTree.ElementNS<a>,
    y: VirtualDomTree.ElementNS<a>,
    targetDomElement: DOM.Element,
    patches: List.Type<Patch>,
    downstreamNodes: List.Type<DownstreamNode<a, b>>,
): DiffResult<a, b> {
    if (x.ns !== y.ns || x.tagName !== y.tagName)
        return { patches: List.mkCons(Patch.mkRedraw(targetDomElement, y), patches), downstreamNodes }

    const xFacts = x.facts && LazyMorphism.unsafe_evaluate(x.facts, organizeFacts(x.tagName))
    const yFacts = y.facts && LazyMorphism.unsafe_evaluate(y.facts, organizeFacts(x.tagName))

    if (xFacts !== undefined || yFacts !== undefined) {
        const diff = diffFacts(xFacts, yFacts)

        if (diff !== undefined) patches = List.mkCons(Patch.mkFacts(targetDomElement, diff), patches)
    }

    const xChildren = x.children && LazyMorphism.unsafe_evaluate(x.children, parseChildren)
    const yChildren = y.children && LazyMorphism.unsafe_evaluate(y.children, parseChildren)

    return Children.diff(xChildren, yChildren, targetDomElement, patches, downstreamNodes)
}

function isEmptyObject(o: {}): boolean {
    let a = true

    for (const _ in o) {
        a = false
        break
    }

    return a
}

function diffCustomHtmlElement<a, b>(
    x: VirtualDomTree.CustomHtmlElement<a>,
    y: VirtualDomTree.CustomHtmlElement<a>,
    targetDomElement: DOM.Element,
    patches: List.Type<Patch>,
    downstreamNodes: List.Type<DownstreamNode<a, b>>,
): DiffResult<a, b> {
    const isNotSameNs = x.ns !== y.ns
    const isNotSameTagName = x.tagName !== y.tagName

    if (isNotSameNs || isNotSameTagName)
        return { downstreamNodes, patches: List.mkCons(Patch.mkRedraw(targetDomElement, y), patches) }

    const xFacts = x.facts && LazyMorphism.unsafe_evaluate(x.facts, organizeFacts(x.tagName))
    const yFacts = y.facts && LazyMorphism.unsafe_evaluate(y.facts, organizeFacts(x.tagName))

    if (xFacts !== undefined || yFacts !== undefined) {
        const diff = diffFacts(xFacts, yFacts)

        if (diff !== undefined) {
            // send fact diff to custom element to decide new render
            unsafe_applyFacts(targetDomElement, diff)
            // patches = List.mkCons(Patch.mkFacts(targetDomElement, diff), patches)
        }
    }

    const xSlots = x.slots
    const ySlots = y.slots

    const isXSlotsEmpty = xSlots === undefined || isEmptyObject(xSlots)
    const isYSlotsEmpty = ySlots === undefined || isEmptyObject(ySlots)

    if (isXSlotsEmpty && isYSlotsEmpty) return { patches, downstreamNodes }
    if (isXSlotsEmpty)
        return { downstreamNodes, patches: List.mkCons(Patch.mkRedrawSlots(targetDomElement, ySlots!), patches) }
    if (isYSlotsEmpty) return { downstreamNodes, patches: List.mkCons(Patch.mkCastrate(targetDomElement), patches) }

    for (const name in xSlots) {
        if (name in ySlots!) {
            const xChildren = parseChildren(xSlots[name])
            const yChildren = parseChildren(ySlots![name])

            const result = Children.diff(xChildren, yChildren, targetDomElement, patches, downstreamNodes, name)
            patches = result.patches
            downstreamNodes = result.downstreamNodes

            continue
        }

        patches = List.mkCons(Patch.mkRemoveSlot(targetDomElement, name), patches)
    }

    for (const name in ySlots) {
        if (name in xSlots!) continue

        const children = parseChildren(ySlots[name])

        patches = List.mkCons(Patch.mkAddSlot(targetDomElement, name, children), patches)
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

function parseChildren<message>(
    vNodes: VirtualDomTree<message> | ReadonlyArray<VirtualDomTree<message>>,
): Children.Type<message> {
    vNodes = Array.isArray(vNodes) ? vNodes : [vNodes]

    return vNodes[0]?.tag === VirtualDomTree.Keyed
        ? Children.mkKeyed(<ReadonlyArray<VirtualDomTree.Keyed<VirtualDomTree<message>>>>vNodes)
        : Children.mkPairwise(vNodes)
}

function parseSlots<message>(slots: {
    [key: string]: VirtualDomTree<message> | ReadonlyArray<VirtualDomTree<message>>
}): { [key: string]: Children.Type<message> } {
    return <any>undefined
}
