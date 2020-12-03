/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
 * Copyright  : (c) 2020 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { VirtualDomTree, realize } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import { OrganizedFacts, unsafe_applyFacts } from 'monarch/Monarch/VirtualDom/Facts'
export type Patch = Patch.Redraw | Patch.Text | Patch.Facts | Patch.RemoveFromEnd | Patch.Append

export namespace Patch {
    /**
     * Disjoint union tags for `Patch` type
     */
    const enum Tag {
        Redraw,
        Text,
        Facts,
        RemoveFromEnd,
        Append,
    }

    // SUM TYPE: Redraw

    /**
     * `Redraw` tag
     *
     * Use it for pattern matching.
     */
    export const Redraw = Tag.Redraw
    /**
     * `Redraw` type constructor
     */
    export interface Redraw extends Tagged<typeof Redraw> {
        vNode: VirtualDomTree<any>
    }
    /**
     * Smart data constructor for `Redraw` type
     */
    export function mkRedraw(vNode: VirtualDomTree<any>): Redraw {
        return { tag: Redraw, vNode }
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

    // SUM TYPE: Facts

    /**
     * `Facts` tag
     *
     * Use it for pattern matching.
     */
    export const Facts = Tag.Facts
    /**
     * `Facts` type constructor
     */
    export interface Facts extends Tagged<typeof Facts> {
        diff: OrganizedFacts
    }
    /**
     * Smart data constructor for `Facts` type
     */
    export function mkFacts(diff: OrganizedFacts): Facts {
        return { tag: Facts, diff }
    }

    // SUM TYPE: RemoveFromEnd

    /**
     * `RemoveFromEnd` tag
     *
     * Use it for pattern matching.
     */
    export const RemoveFromEnd = Tag.RemoveFromEnd
    /**
     * `RemoveFromEnd` type constructor
     */
    export interface RemoveFromEnd extends Tagged<typeof RemoveFromEnd> {
        delta: number
    }
    /**
     * Smart data constructor for `RemoveFromEnd` type
     */
    export function mkRemoveFromEnd(delta: number): RemoveFromEnd {
        return { tag: RemoveFromEnd, delta }
    }

    // SUM TYPE: Appeend

    /**
     * `Append` tag
     *
     * Use it for pattern matching.
     */
    export const Append = Tag.Append
    /**
     * `Append` type constructor
     */
    export interface Append extends Tagged<typeof Append> {
        children: readonly VirtualDomTree<any>[]
        from: number
    }
    /**
     * Smart data constructor for `Append` type
     */
    export function mkAppend<message>(children: readonly VirtualDomTree<message>[], from = 0): Append {
        return { tag: Append, children, from }
    }
}

export function unsafe_applyPatch(domNode: Node, patch: Patch): void {
    switch (patch.tag) {
        case Patch.Text:
            return unsafe_applyTextPatch(<Text>domNode, patch)

        case Patch.Redraw:
            return unsafe_applyRedrawPatch(domNode, patch)

        case Patch.Facts:
            return unsafe_applyFacts(domNode, patch.diff)

        case Patch.RemoveFromEnd:
            return unsafe_applyRemoveFromEndPatch(domNode, patch)

        case Patch.Append:
            return unsafe_applyAppendPatch(domNode, patch)
    }
}

function unsafe_applyTextPatch(textNode: Text, { text }: Patch.Text): void {
    textNode.replaceData(0, text.length, text)
}

function unsafe_applyRedrawPatch(oldDomNode: Node, { vNode }: Patch.Redraw): void {
    const newDomNode = realize(vNode, oldDomNode.monarch_outputHandlerNode!)

    oldDomNode.parentNode!.replaceChild(newDomNode, oldDomNode)
}

function unsafe_applyRemoveFromEndPatch(domNode: Node, { delta }: Patch.RemoveFromEnd): void {
    for (let i = 0; i < delta; i++) {
        domNode.removeChild(domNode.childNodes[domNode.childNodes.length - 1])
    }
}

function unsafe_applyAppendPatch(domNode: Node, { children, from }: Patch.Append): void {
    let ix = from
    const fragment = ix === children.length - 1 ? domNode : document.createDocumentFragment()

    for (; ix < children.length; ix++) {
        fragment.appendChild(realize(children[ix], domNode.monarch_outputHandlerNode!))
    }

    if (fragment !== domNode) {
        domNode.appendChild(fragment)
    }
}
