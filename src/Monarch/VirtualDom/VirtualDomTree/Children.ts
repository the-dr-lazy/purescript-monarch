/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { VirtualDomTree, DownstreamNode, DiffResult, realize } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import * as List from 'monarch/Monarch/Data/List'
import { Patch } from 'monarch/Monarch/VirtualDom/Patch'
import { ReorderHistory } from 'monarch/Monarch/VirtualDom/ReorderHistory'
import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'

/**
 * Children of virtual DOM tree ADT
 */
export type Type<message> = Pairwise<message> | Keyed<message>

export function diff<a, b>(
    x: Type<a> | undefined,
    y: Type<b> | undefined,
    parentDomElement: DOM.Element,
    patches: List.Type<Patch>,
    downstreamNodes: List.Type<DownstreamNode<a, b>>,
    slotName?: string,
): DiffResult<a, b> {
    const isXEmpty = x === undefined || x.value.length === 0
    const isYEmpty = y === undefined || y.value.length === 0

    if (isXEmpty && isYEmpty) return { patches, downstreamNodes }
    if (isYEmpty)
        return {
            downstreamNodes,
            patches: List.mkCons(
                slotName === undefined
                    ? Patch.mkCastrate(parentDomElement)
                    : Patch.mkRemoveSlot(parentDomElement, slotName),
                patches,
            ),
        }
    if (isXEmpty || x!.tag !== y!.tag)
        return {
            patches: List.mkCons(
                slotName === undefined
                    ? Patch.mkChildrenRedraw(parentDomElement, y!)
                    : Patch.mkRedrawSlot(parentDomElement, slotName, y!),
                patches,
            ),
            downstreamNodes,
        }

    switch (x!.tag) {
        case Tag.Pairwise:
            return diffPairwise(<Pairwise<a>>x, <Pairwise<b>>y, parentDomElement, patches, downstreamNodes)
        case Tag.Keyed:
            return diffKeyed(<Keyed<a>>x, <Keyed<b>>y, parentDomElement, patches, downstreamNodes)
    }
}

/**
 * Disjoint union tags for `Children` type
 */
export const enum Tag {
    Pairwise,
    Keyed,
}

// SUM TYPE: Pairwise

export interface Pairwise<message> {
    tag: Tag.Pairwise
    value: ReadonlyArray<VirtualDomTree<message>>
}

export function mkPairwise<message>(value: ReadonlyArray<VirtualDomTree<message>>): Pairwise<message> {
    return { tag: Tag.Pairwise, value }
}

export function diffPairwise<a, b>(
    { value: xs }: Pairwise<a>,
    { value: ys }: Pairwise<b>,
    parentDomElement: DOM.Element,
    patches: List.Type<Patch>,
    downstreamNodes: List.Type<DownstreamNode<a, b>>,
): DiffResult<a, b> {
    const xsLength = xs.length
    const ysLength = ys.length

    if (xsLength > ysLength) {
        patches = List.mkCons(Patch.mkRemoveFromEnd(parentDomElement, xsLength - ysLength), patches)
    } else if (xsLength < ysLength) {
        patches = List.mkCons(Patch.mkAppend(parentDomElement, ys!, xsLength), patches)
    }

    const minChildrenLength = Math.min(xsLength, ysLength)
    const childDomNodes = parentDomElement.childNodes

    for (let ix = 0; ix < minChildrenLength; ix++) {
        downstreamNodes = List.mkCons({ x: xs![ix], y: ys![ix], targetDomNode: childDomNodes[ix] }, downstreamNodes)
    }

    return { downstreamNodes, patches }
}

// SUM TYPE: Keyed

export interface Keyed<message> {
    tag: Tag.Keyed
    value: ReadonlyArray<VirtualDomTree.Keyed<VirtualDomTree<message>>>
}

export function mkKeyed<message>(value: ReadonlyArray<VirtualDomTree.Keyed<VirtualDomTree<message>>>): Keyed<message> {
    return { tag: Tag.Keyed, value }
}

export function diffKeyed<a, b>(
    { value: xs }: Keyed<a>,
    { value: ys }: Keyed<b>,
    parentDomElement: DOM.Element,
    patches: List.Type<Patch>,
    downstreamNodes: List.Type<DownstreamNode<a, b>>,
): DiffResult<a, b> {
    const xsLength = xs.length
    const ysLength = ys.length

    const history: ReorderHistory<a, b> = ReorderHistory.mk()
    const childDomNodes = parentDomElement.childNodes

    let xIx = 0
    let yIx = 0

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
            downstreamNodes = List.mkCons({ x, y, targetDomNode: childDomNodes[yIx] }, downstreamNodes)

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
            downstreamNodes = List.mkCons({ x, y: nextY, targetDomNode: childDomNodes[yIx + 1] }, downstreamNodes)

            downstreamNodes = ReorderHistory.unsafe_move(
                yKey,
                nextX,
                xIx + 1,
                y,
                yIx,
                childDomNodes,
                downstreamNodes,
                history,
            )

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
            downstreamNodes = List.mkCons({ x, y: nextY, targetDomNode: childDomNodes[yIx + 1] }, downstreamNodes)

            downstreamNodes = ReorderHistory.unsafe_insert(yKey, y, yIx, childDomNodes, downstreamNodes, history)

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
            downstreamNodes = List.mkCons({ x: nextX, y, targetDomNode: childDomNodes[yIx] }, downstreamNodes)

            downstreamNodes = ReorderHistory.unsafe_remove(xKey, x, xIx, childDomNodes, downstreamNodes, history)

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
            downstreamNodes = List.mkCons(
                { x: nextX, y: nextY, targetDomNode: childDomNodes[yIx + 1] },
                downstreamNodes,
            )

            downstreamNodes = ReorderHistory.unsafe_remove(xKey, x, xIx, childDomNodes, downstreamNodes, history)
            downstreamNodes = ReorderHistory.unsafe_insert(yKey, y, yIx, childDomNodes, downstreamNodes, history)

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

        downstreamNodes = ReorderHistory.unsafe_remove(xKey, x, xIx, childDomNodes, downstreamNodes, history)

        xIx += 1
    }

    // Consume rest of new children and candidate them for inserting.
    while (yIx < ysLength) {
        const y = ys![yIx]
        const yKey = y.key

        downstreamNodes = ReorderHistory.unsafe_insert(yKey, y, yIx, childDomNodes, downstreamNodes, history, true)

        yIx += 1
    }

    return { downstreamNodes, patches: List.mkCons(Patch.mkReorder(parentDomElement, history), patches) }
}

export function unsafe_realize<message>(
    { value }: Type<message>,
    outputHandlers: OutputHandlersList,
    unsafe_push: (domNode: DOM.Node) => void,
): void {
    const length = value.length

    for (let ix = 0; ix < length; ix++) {
        unsafe_push(realize(value[ix], outputHandlers))
    }
}
