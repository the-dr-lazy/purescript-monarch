/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2021 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import 'setimmediate'
import { VirtualDomTree, realize, diff, DownstreamNode } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import { PatchTree, unsafe_uncurried_applyPatchTree } from 'monarch/Monarch/VirtualDom/PatchTree'
import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'

export function unsafe_uncurried_mount<a>(domNode: Node, outputHandlers: OutputHandlersList.Nil, vNode: VirtualDomTree<a>): void {
    while (domNode.firstChild) {
        domNode.removeChild(domNode.lastChild!)
    }

    domNode.appendChild(realize(vNode, outputHandlers))
}

// prettier-ignore
interface Mount {
    (spec: { container: Node, outputHandlers: OutputHandlersList.Nil }): <message>(vNode: VirtualDomTree<message>) => Effect<Unit>
}

// prettier-ignore
export const mount: Mount = ({ container, outputHandlers }) => vNode =>
    () => unsafe_uncurried_mount(container, outputHandlers, vNode)

type DiffWorkQueue<a, b> = Array<{
    address: number[]
    patchTree: PatchTree
    downstreamNodes: DownstreamNode<a, b>[]
}>

interface DiffWorkState<a, b> {
    rootVNode: VirtualDomTree<b>
    rootPatchTree?: PatchTree.Root
    firstUpstreamPatchTree?: PatchTree
    address: PatchTree.Address
    queue: DiffWorkQueue<a, b>
}

interface DiffWork<a, b> {
    node: DownstreamNode<a, b>
    state: DiffWorkState<a, b>
}

// prettier-ignore
interface MkDiffWork {
    <a>(commitedVNode: VirtualDomTree<a>): <b>(vNode: VirtualDomTree<b>) => DiffWork<a, b>
}

export const mkDiffWork: MkDiffWork = x => y => ({
    node: { x, y, ix: 0 },
    state: {
        rootVNode: y,
        address: [],
        queue: [],
    },
})

interface Scheduler {
    shouldYieldToBrowser: Effect<boolean>
    promoteDeadline: Effect<Unit>
}

interface UnsafeDiffWorkEnvironment<a, b> {
    dispatchDiffWork(work: DiffWork<a, b>): void
    finishDiffWork(spec: Pick<DiffWorkState<a, b>, 'rootVNode' | 'rootPatchTree'>): void
    scheduler: Scheduler
}

/**
 * ToDo: document this function.
 */
export function unsafe_uncurried_performDiffWork<a, b>(
    work: DiffWork<a, b>,
    { scheduler, finishDiffWork, dispatchDiffWork }: UnsafeDiffWorkEnvironment<a, b>,
): void {
    const { state } = work

    let node: DownstreamNode<a, b> | undefined = work.node

    scheduler.promoteDeadline()

    while (node && !scheduler.shouldYieldToBrowser()) {

        const { patches, downstreamNodes } = diff(node.x, node.y)

        let patchTree

        if (state.firstUpstreamPatchTree && node.ix !== undefined && patches.length !== 0) {
            state.firstUpstreamPatchTree.children = state.firstUpstreamPatchTree.children || []

            patchTree = { address: [...state.address, node.ix], patches }

            state.firstUpstreamPatchTree.children.push(patchTree)
        } else if (state.firstUpstreamPatchTree) {
            if (node.ix === undefined && patches.length !== 0) {
                Array.prototype.push.apply(state.firstUpstreamPatchTree.patches, patches)
            }

            patchTree = state.firstUpstreamPatchTree
        } else {
            state.rootPatchTree = {
                children: [{ address: [0], patches: patches.length !== 0 ? patches : undefined }],
            }

            patchTree = state.firstUpstreamPatchTree = state.rootPatchTree.children![0]
        }

        if (downstreamNodes && downstreamNodes.length !== 0) {
            state.queue.push({
                address: patches.length !== 0 || node.ix === undefined ? [] : [...state.address, node.ix],
                patchTree,
                downstreamNodes,
            })
        }

        node = state.queue[0]?.downstreamNodes.shift()

        if (node === undefined) {
            state.queue.shift()
            state.firstUpstreamPatchTree = state.queue[0]?.patchTree
            state.address = state.queue[0]?.address

            node = state.queue[0]?.downstreamNodes.shift()
        }
    }

    if (node) {
        dispatchDiffWork({ node, state })

        return
    }

    finishDiffWork(work.state)
}

interface DiffWorkEnvironment<a, b> {
    dispatchDiffWork(work: DiffWork<a, b>): Effect<Unit>
    finishDiffWork(spec: Pick<DiffWorkState<a, b>, 'rootVNode' | 'rootPatchTree'>): Effect<Unit>
    scheduler: Scheduler
}

// prettier-ignore
interface PerformDiffWork {
    <a, b>(environment: DiffWorkEnvironment<a, b>): (work: DiffWork<a, b>) => Effect<Unit>
}

// prettier-ignore
export const performDiffWork: PerformDiffWork = ({ scheduler, finishDiffWork, dispatchDiffWork }) => {
    const environment: UnsafeDiffWorkEnvironment<any, any> = {
        scheduler,
        finishDiffWork(...args) {
            return finishDiffWork(...args)()
        },
        dispatchDiffWork(...args) {
            return dispatchDiffWork(...args)()
        }
    }

    return work => () => unsafe_uncurried_performDiffWork(work, environment)
}

// prettier-ignore
interface ApplyPatchTree {
    (container: Node): (patchTree: PatchTree) => Effect<Unit>
}

// prettier-ignore
export const applyPatchTree: ApplyPatchTree = container => patchTree =>
    () => unsafe_uncurried_applyPatchTree(container, patchTree)

// prettier-ignore
interface Unmount {
    <message>(domNode: Node): (vNode: VirtualDomTree<message>) => Effect<Unit>
}

// prettier-ignore
export const unmount: Unmount = domNode => vNode =>
    () => undefined // TODO: should be implemented
