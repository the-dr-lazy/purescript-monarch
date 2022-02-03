/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { VirtualDomTree, realize } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import { OrganizedFacts, unsafe_applyFacts } from 'monarch/Monarch/VirtualDom/Facts'
import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'
import { ReorderHistory } from 'monarch/Monarch/VirtualDom/ReorderHistory'
import { ChildNodeByKeyMap } from './ChildNodeByKeyMap'
import * as Children from 'monarch/Monarch/VirtualDom/VirtualDomTree/Children'

/**
 * Patch ADT
 */
export type Patch =
    | Patch.Redraw
    | Patch.Text
    | Patch.Facts
    | Patch.RedrawChildren
    // | Patch.RemoveFromEnd
    // | Patch.Append
    // | Patch.Castrate
    | Patch.Tagger
    | Patch.Reorder
    | Patch.AddSlot
    | Patch.RemoveSlot
    | Patch.RedrawSlot

export namespace Patch {
    /**
     * Disjoint union tags for `Patch` type
     *
     * Note: Don't use the 4x for any other tagged unions.
     */
    const enum Tag {
        Redraw = 40,
        RedrawChildren = 41,
        Text = 42,
        Facts = 43,
        RemoveFromEnd = 44,
        Append = 45,
        Tagger = 46,
        Reorder = 47,
        Castrate = 48,
        RemoveSlot = 49,
        AddSlot = 410,
        RedrawSlots = 411,
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
        targetDomNode: DOM.Node
    }
    /**
     * Smart data constructor for `Redraw` type
     */
    export function mkRedraw(targetDomNode: DOM.Node, vNode: VirtualDomTree<any>): Redraw {
        return { tag: Redraw, vNode, targetDomNode }
    }

    // SUM TYPE: RedrawChildren

    export const RedrawChildren = Tag.RedrawChildren

    export interface RedrawChildren extends Tagged<Tag.RedrawChildren> {
        targetDomNode: DOM.ParentNode
        children: Children.Type<any>
    }

    export function mkRedrawChildren(targetDomNode: DOM.ParentNode, children: Children.Type<any>): RedrawChildren {
        return { tag: RedrawChildren, targetDomNode, children }
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
        targetTextNode: DOM.Text
    }
    /**
     * Smart data constructor for `Text` type
     */
    export function mkText(targetTextNode: DOM.Text, text: string): Text {
        return { tag: Text, text, targetTextNode }
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
        targetDomElement: DOM.Element
    }
    /**
     * Smart data constructor for `Facts` type
     */
    export function mkFacts(targetDomElement: DOM.Element, diff: OrganizedFacts): Facts {
        return { tag: Facts, diff, targetDomElement }
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
        targetDomNode: DOM.ParentNode
    }
    /**
     * Smart data constructor for `RemoveFromEnd` type
     */
    export function mkRemoveFromEnd(targetDomNode: DOM.ParentNode, delta: number): RemoveFromEnd {
        return { tag: RemoveFromEnd, delta, targetDomNode }
    }

    // SUM TYPE: Append

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
        children: ReadonlyArray<VirtualDomTree<any>>
        from: number
        targetDomNode: DOM.ParentNode
    }
    /**
     * Smart data constructor for `Append` type
     */
    export function mkAppend(
        targetDomNode: DOM.ParentNode,
        children: ReadonlyArray<VirtualDomTree<any>>,
        from = 0,
    ): Append {
        return { tag: Append, children, from, targetDomNode }
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
        targetDomNode: DOM.Node
    }
    /**
     * Smart data constructor for `Tagger` type
     */
    export function mkTagger(targetDomNode: DOM.Node, fs: Function | Function[]): Tagger {
        return { tag: Tagger, fs, targetDomNode }
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
        targetDomNode: DOM.ParentNode
    }
    /**
     * Smart data constructor for `Reorder` type
     */
    export function mkReorder<a, b>(targetDomNode: DOM.ParentNode, history: ReorderHistory<a, b>): Reorder {
        return { tag: Reorder, history, targetDomNode }
    }

    // SUM TYPE: Castrate
    export const Castrate = Tag.Castrate

    export interface Castrate extends Tagged<typeof Castrate> {
        targetDomNode: DOM.ParentNode
    }

    export function mkCastrate(targetDomNode: DOM.ParentNode): Castrate {
        return { tag: Tag.Castrate, targetDomNode }
    }

    // SUM TYPE: RemoveSlot
    export const RemoveSlot = Tag.RemoveSlot

    export interface RemoveSlot extends Tagged<Tag.RemoveSlot> {
        targetDomElement: DOM.Element
        name: string
    }

    export function mkRemoveSlot(targetDomElement: DOM.Element, name: string): RemoveSlot {
        return { tag: Tag.RemoveSlot, targetDomElement, name }
    }

    // SUM TYPE: AddSlot
    //
    export const AddSlot = Tag.AddSlot

    export interface AddSlot extends Tagged<Tag.AddSlot> {
        targetDomElement: DOM.Element
        name: string
        children: Children.Type<any>
    }

    export function mkAddSlot(targetDomElement: DOM.Element, name: string, children: Children.Type<any>): AddSlot {
        return { tag: AddSlot, targetDomElement, name, children }
    }

    // SUM TYPE: Redraw Slots
    export const RedrawSlots = Tag.RedrawSlots

    export interface RedrawSlots extends Tagged<Tag.RedrawSlots> {
        targetDomElement: DOM.Element
        slots: any
    }

    export function mkRedrawSlots(): RedrawSlots {
        return { jk }
    }
}

export function unsafe_applyPatch(patch: Patch): void {
    switch (patch.tag) {
        case Patch.Redraw:
            return unsafe_applyRedrawPatch(patch)
        case Patch.RedrawChildren:
            return unsafe_applyRedrawChildrenPatch(patch)
        case Patch.Text:
            return unsafe_applyTextPatch(patch)
        case Patch.Facts:
            return unsafe_applyFacts(patch.targetDomElement, patch.diff)
        case Patch.RemoveFromEnd:
            return unsafe_applyRemoveFromEndPatch(patch)
        case Patch.Append:
            return unsafe_applyAppendPatch(patch)
        case Patch.Tagger:
            return unsafe_applyTaggerPatch(patch)
        case Patch.Reorder:
            return unsafe_applyReorderPatch(patch)
        case Patch.Castrate:
            return unsafe_applyCastratePatch(patch)
    }
}

function unsafe_applyRedrawPatch({ vNode, targetDomNode }: Patch.Redraw): void {
    const newDomNode = realize(vNode, targetDomNode.__MONARCH_UNSAFE_OUTPUT_HANDLERS!)

    targetDomNode.parentNode!.replaceChild(newDomNode, targetDomNode)
}

function unsafe_applyRedrawChildrenPatch({ targetDomNode, children }: Patch.RedrawChildren): void {
    const childDomNodes: Array<DOM.Node> = []

    Children.unsafe_realize(children, targetDomNode.__MONARCH_UNSAFE_OUTPUT_HANDLERS, childDomNodes.push)

    targetDomNode.replaceChildren(...childDomNodes)
}

function unsafe_applyTextPatch({ text, targetTextNode }: Patch.Text): void {
    targetTextNode.replaceData(0, targetTextNode.length, text)
}

function unsafe_applyRemoveFromEndPatch({ delta, targetDomNode }: Patch.RemoveFromEnd): void {
    for (let i = 0; i < delta; i++) {
        targetDomNode.removeChild(targetDomNode.childNodes[targetDomNode.childNodes.length - 1])
    }
}

function unsafe_applyAppendPatch({ children, from, targetDomNode }: Patch.Append): void {
    let ix = from
    const fragment = ix === children.length - 1 ? targetDomNode : document.createDocumentFragment()

    for (; ix < children.length; ix++) {
        fragment.appendChild(realize(children[ix], targetDomNode.__MONARCH_UNSAFE_OUTPUT_HANDLERS!))
    }

    if (fragment !== targetDomNode) targetDomNode.appendChild(fragment)
}

function unsafe_applyTaggerPatch({ fs, targetDomNode }: Patch.Tagger): void {
    ;(<OutputHandlersList.Cons>targetDomNode.__MONARCH_UNSAFE_OUTPUT_HANDLERS).value = fs
}

function unsafe_applyReorderPatch({ history: { commitByKey, endInsertKeys }, targetDomNode }: Patch.Reorder): void {
    const childNodeByKey: ChildNodeByKeyMap = new Map()

    for (let [key, commit] of commitByKey) {
        if (commit.tag === ReorderHistory.Commit.Insert) continue

        const ix = commit.tag === ReorderHistory.Commit.Move ? commit.fromIx : commit.ix

        childNodeByKey.set(key, targetDomNode.childNodes[ix])
    }

    let fragment: Node | undefined
    switch (endInsertKeys.size) {
        case 0:
            fragment = undefined
            break
        case 1:
            const key = endInsertKeys.values().next().value
            const commit = <ReorderHistory.Commit.Insert<any> | ReorderHistory.Commit.Move>commitByKey.get(key)!
            const node = ReorderHistory.Commit.push(
                key,
                commit,
                childNodeByKey,
                targetDomNode.__MONARCH_UNSAFE_OUTPUT_HANDLERS!,
            )
            fragment = node
            break
        default:
            fragment = document.createDocumentFragment()

            for (let key of endInsertKeys) {
                const commit = <ReorderHistory.Commit.Insert<any> | ReorderHistory.Commit.Move>commitByKey.get(key)!
                const node = ReorderHistory.Commit.push(
                    key,
                    commit,
                    childNodeByKey,
                    targetDomNode.__MONARCH_UNSAFE_OUTPUT_HANDLERS!,
                )

                fragment!.appendChild(node)
            }
    }

    const removedKeys = []

    for (let [key, commit] of commitByKey) {
        if (commit.tag === ReorderHistory.Commit.Remove) {
            removedKeys.push(key)

            continue
        }

        if (endInsertKeys.has(key)) continue

        const node = ReorderHistory.Commit.push(
            key,
            commit,
            childNodeByKey,
            targetDomNode.__MONARCH_UNSAFE_OUTPUT_HANDLERS!,
        )
        const ix = commit.tag === ReorderHistory.Commit.Move ? commit.toIx : commit.ix

        targetDomNode.insertBefore(node, targetDomNode.childNodes[ix])
    }

    for (let ix = 0; ix < removedKeys.length; ix++) {
        const key = removedKeys[ix]
        const node = childNodeByKey.get(key)!

        targetDomNode.removeChild(node)
    }

    fragment && targetDomNode.appendChild(fragment)
}

function unsafe_applyCastratePatch({ targetDomNode }: Patch.Castrate): void {
    targetDomNode.replaceChildren()
}
