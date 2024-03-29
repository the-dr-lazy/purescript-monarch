/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { VirtualDomTree, realize } from './VirtualDomTree'
import { OrganizedFacts, unsafe_applyFacts } from './Facts'
import { OutputHandlersList } from './OutputHandlersList'
import { ReorderHistory } from './ReorderHistory'
import { ChildNodeByKeyMap } from './ChildNodeByKeyMap'

/**
 * Patch ADT
 */
export type Patch =
    | Patch.Redraw
    | Patch.Text
    | Patch.Facts
    | Patch.RemoveFromEnd
    | Patch.Append
    | Patch.Tagger
    | Patch.Reorder

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
        Tagger,
        Reorder,
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

    // SUM TYPE: Tagger

    /**
     * `Tagger` tag
     *
     * Use it for pattern matching.
     */
    export const Tagger = Tag.Tagger
    /**
     * `Tagger` type constructor
     */
    export interface Tagger extends Tagged<typeof Tagger> {
        fs: Function | Function[]
    }
    /**
     * Smart data constructor for `Tagger` type
     */
    export function mkTagger(fs: Function | Function[]): Tagger {
        return { tag: Tagger, fs }
    }

    // SUM TYPE: Reorder

    /**
     * `Reorder` tag
     *
     * Use it for pattern matching.
     */
    export const Reorder = Tag.Reorder
    /**
     * `Reorder` type constructor
     */
    export interface Reorder extends Tagged<typeof Reorder> {
        history: ReorderHistory<unknown, unknown>
    }
    /**
     * Smart data constructor for `Reorder` type
     */
    export function mkReorder<a, b>(history: ReorderHistory<a, b>): Reorder {
        return { tag: Reorder, history }
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

        case Patch.Tagger:
            return unsafe_applyTaggerPatch(domNode, patch)

        case Patch.Reorder:
            return unsafe_applyReorderPatch(domNode, patch)
    }
}

function unsafe_applyTextPatch(textNode: Text, { text }: Patch.Text): void {
    textNode.replaceData(0, textNode.length, text)
}

function unsafe_applyRedrawPatch(oldDomNode: Node, { vNode }: Patch.Redraw): void {
    const newDomNode = realize(vNode, oldDomNode.monarch_outputHandlers!)

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
        fragment.appendChild(realize(children[ix], domNode.monarch_outputHandlers!))
    }

    if (fragment !== domNode) {
        domNode.appendChild(fragment)
    }
}

function unsafe_applyTaggerPatch(domNode: Node, { fs }: Patch.Tagger): void {
    ;(<OutputHandlersList.Cons>domNode.monarch_outputHandlers).value = fs
}

function unsafe_applyReorderPatch(domNode: Node, { history: { commitByKey, endInsertKeys } }: Patch.Reorder): void {
    const childNodeByKey: ChildNodeByKeyMap = new Map()

    for (let [key, commit] of commitByKey) {
        if (commit.tag === ReorderHistory.Commit.Insert) continue

        const ix = commit.tag === ReorderHistory.Commit.Move ? commit.fromIx : commit.ix

        childNodeByKey.set(key, domNode.childNodes[ix])
    }

    const fragment: Node | undefined = (() => {
        switch (endInsertKeys.size) {
            case 0:
                return undefined
            case 1:
                const key = endInsertKeys.values().next().value
                const commit = <ReorderHistory.Commit.Insert<any> | ReorderHistory.Commit.Move>commitByKey.get(key)!
                const node = ReorderHistory.Commit.push(key, commit, childNodeByKey, domNode.monarch_outputHandlers!)
                return node
            default:
                const fragment = document.createDocumentFragment()

                for (let key of endInsertKeys) {
                    const commit = <ReorderHistory.Commit.Insert<any> | ReorderHistory.Commit.Move>commitByKey.get(key)!
                    const node = ReorderHistory.Commit.push(
                        key,
                        commit,
                        childNodeByKey,
                        domNode.monarch_outputHandlers!,
                    )

                    fragment!.appendChild(node)
                }

                return fragment
        }
    })()

    const removedKeys = []

    for (let [key, commit] of commitByKey) {
        if (commit.tag === ReorderHistory.Commit.Remove) {
            removedKeys.push(key)

            continue
        }

        if (endInsertKeys.has(key)) continue

        const node = ReorderHistory.Commit.push(key, commit, childNodeByKey, domNode.monarch_outputHandlers!)
        const ix = commit.tag === ReorderHistory.Commit.Move ? commit.toIx : commit.ix

        domNode.insertBefore(node, domNode.childNodes[ix])
    }

    for (let ix = 0; ix < removedKeys.length; ix++) {
        const key = removedKeys[ix]
        const node = childNodeByKey.get(key)!

        domNode.removeChild(node)
    }

    fragment && domNode.appendChild(fragment)
}
