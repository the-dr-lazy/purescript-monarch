/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { VirtualDomTree, DownstreamNode, DiffResult, diff } from './VirtualDomTree'
import { Scheduler } from '../Scheduler'
import * as List from 'monarch/Monarch/Data/List'
import { Patch } from 'monarch/Monarch/VirtualDom/Patch'

interface State<a, b> {
    rootVNode: VirtualDomTree<b>
    patches: List.Type<Patch>
    downstreamNodes: List.Type<DownstreamNode<a, b>>
}

export interface DiffWork<a, b> {
    node: DownstreamNode<a, b>
    state: State<a, b>
}

export function mkRootDiffWork<a, b>(
    x: VirtualDomTree<a>,
    y: VirtualDomTree<b>,
    rootDomNode: DOM.Node,
): DiffWork<a, b> {
    return {
        node: { x, y, targetDomNode: rootDomNode },
        state: {
            rootVNode: y,
            patches: List.nil,
            downstreamNodes: List.nil,
        },
    }
}

export interface DiffWorkResult<message> {
    rootVNode: VirtualDomTree<message>
    patches: List.Type<Patch>
}

export interface DiffWorkEnvironment<a, b> {
    unsafe_dispatchDiffWork(work: DiffWork<a, b>): void
    unsafe_finishDiffWork(result: DiffWorkResult<b>): void
    scheduler: Scheduler
}

/**
 * ToDo: document this function.
 */
export function unsafe_uncurried_performDiffWork<a, b>(
    work: DiffWork<a, b>,
    { scheduler, unsafe_finishDiffWork, unsafe_dispatchDiffWork }: DiffWorkEnvironment<a, b>,
): void {
    const { state } = work

    let node: DownstreamNode<a, b> | undefined = work.node

    scheduler.unsafe_promoteDeadline()

    while (node !== undefined && !scheduler.unsafe_shouldYieldToBrowser()) {
        const result: DiffResult<a, b> = diff(node.x, node.y, node.targetDomNode, state.patches, state.downstreamNodes)
        state.patches = result.patches
        state.downstreamNodes = result.downstreamNodes

        node = undefined

        if (state.downstreamNodes.tag !== List.Tag.Nil) {
            node = state.downstreamNodes.head

            state.downstreamNodes = state.downstreamNodes.tail
        }
    }

    if (node !== undefined) return unsafe_dispatchDiffWork({ node, state })

    unsafe_finishDiffWork(<DiffWorkResult<b>>(<unknown>work.state))
}
