/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2021 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { VirtualDomTree, DownstreamNode, realize } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import { ChildNodeByKeyMap } from './ChildNodeByKeyMap'
import { OutputHandlersList } from './OutputHandlersList'
export type ReorderHistory<a, b> = {
    commitByKey: Map<any, ReorderHistory.Commit<a, b>>
    endInsertKeys: Set<any>
}

export namespace ReorderHistory {
    /**
     * Reorder history commit ADT
     */
    export type Commit<a, b> = Commit.Insert<b> | Commit.Remove<a> | Commit.Move

    export namespace Commit {
        /**
         * Disjoint union tags for `Commit` type
         */
        enum Tag {
            Insert,
            Remove,
            Move,
        }

        // SUM TYPE: Insert

        /**
         * `Insert` tag
         *
         * Use it for pattern matching.
         */
        export const Insert = Tag.Insert
        /**
         * `Insert` type constructor
         */
        export interface Insert<message> extends Tagged<typeof Insert> {
            vNode: VirtualDomTree<message>
            ix: number
        }
        /**
         * Smart data constructor for `Insert` type
         */
        export function mkInsert<message>(vNode: VirtualDomTree<message>, ix: number): Insert<message> {
            return { tag: Insert, vNode, ix }
        }

        // SUM TYPE: Remove

        /**
         * `Remove` tag
         *
         * Use it for pattern matching.
         */
        export const Remove = Tag.Remove

        /**
         * `Remove` type constructor
         */
        export interface Remove<message> extends Tagged<typeof Remove> {
            vNode: VirtualDomTree<message>
            ix: number
        }
        /**
         * Smart data constructor for `Remove` type
         */
        export function mkRemove<message>(vNode: VirtualDomTree<message>, ix: number): Remove<message> {
            return { tag: Remove, vNode, ix }
        }

        // SUM TYPE: Move

        /**
         * `Move` tag
         *
         * Use it for pattern matching.
         */
        export const Move = Tag.Move
        /**
         * `Move` type constructor
         */
        export interface Move extends Tagged<typeof Move> {
            fromIx: number
            toIx: number
        }
        /**
         * Smart data constructor for `Move` type
         */
        export function mkMove(fromIx: number, toIx: number): Move {
            return { tag: Move, fromIx, toIx }
        }

        /**
         * Push a specific commit to the DOM tree.
         */
        export function push<message>(key: any, commit: ReorderHistory.Commit.Insert<message> | ReorderHistory.Commit.Move, childNodeByKey: ChildNodeByKeyMap, outputHandlers: OutputHandlersList): Node {
            switch (commit.tag) {
                case ReorderHistory.Commit.Move: return childNodeByKey.get(key)!
                case ReorderHistory.Commit.Insert:
                    return realize(commit.vNode, outputHandlers)
            }
        }
    }

    /**
     * Make a new `ReorderHistory`
     */
    export function mk<a, b>(): ReorderHistory<a, b> {
        return {
            commitByKey: new Map(),
            endInsertKeys: new Set()
        }
    }

    export function unsafe_insert<a, b>(
        key: any,
        vNode: VirtualDomTree<b>,
        ix: number,
        downstreamNodes: DownstreamNode<a, b>[],
        history: ReorderHistory<a, b>,
        isEndInsert = false
    ): void {
        const { commitByKey, endInsertKeys } = history
        const commit = commitByKey.get(key)

        if (!commit) {
            commitByKey.set(key, Commit.mkInsert(vNode, ix))
            isEndInsert && endInsertKeys.add(key)

            return
        }

        if (commit.tag === Commit.Remove) {
            commitByKey.delete(key)
            commitByKey.set(key, Commit.mkMove(commit.ix, ix))
            isEndInsert && endInsertKeys.add(key)

            downstreamNodes.push({ x: commit.vNode, y: vNode, ix })

            return
        }

        // TODO: warning to the user about duplicate key in development mode
        unsafe_insert(resolveKeyConfliction(key), vNode, ix, downstreamNodes, history)
    }

    export function unsafe_remove<a, b>(
        key: any,
        vNode: VirtualDomTree<a>,
        ix: number,
        downstreamNodes: DownstreamNode<a, b>[],
        history: ReorderHistory<a, b>,
    ): void {
        const { commitByKey } = history
        const commit = commitByKey.get(key)

        if (!commit) {
            commitByKey.set(key, Commit.mkRemove(vNode, ix))

            return
        }

        if (commit.tag === Commit.Insert) {
            commitByKey.set(key, Commit.mkMove(ix, commit.ix))

            downstreamNodes.push({ x: vNode, y: commit.vNode, ix: commit.ix })

            return
        }

        // TODO: warning to the user about duplicate key in development mode
        unsafe_remove(resolveKeyConfliction(key), vNode, ix, downstreamNodes, history)
    }

    export function unsafe_move<a, b>(
        key: any,
        oldVirtualNode: VirtualDomTree<a>,
        fromIx: number,
        newVirtualNode: VirtualDomTree<b>,
        toIx: number,
        downstreamNodes: DownstreamNode<a, b>[],
        history: ReorderHistory<a, b>,
    ): void {
        const { commitByKey } = history
        const commit = commitByKey.get(key)

        if (!commit) {
            commitByKey.set(key, Commit.mkMove(fromIx, toIx))

            downstreamNodes.push({ x: oldVirtualNode, y: newVirtualNode, ix: toIx })

            return
        }

        // TODO: warning to the user about duplicate key in development mode
        unsafe_move(resolveKeyConfliction(key), oldVirtualNode, fromIx, newVirtualNode, toIx, downstreamNodes, history)
    }
}

export function resolveKeyConfliction(key: any) {
    return String(key) + '_monarch_duplicate_key'
}
