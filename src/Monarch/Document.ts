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

import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'
import { VirtualDomTree } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import { unsafe_uncurried_applyPatchTree } from 'monarch/Monarch/VirtualDom/PatchTree'
import { unsafe_uncurried_mount } from 'monarch/Monarch/VirtualDom'
import { DiffWorkEnvironment, DiffWork, DiffWorkResult, mkRootDiffWork, unsafe_uncurried_performDiffWork } from 'monarch/Monarch/VirtualDom/DiffWork'
import { mkScheduler } from 'monarch/Monarch/Scheduler'

interface Spec<input, model, message> {
    input: input
    init(input: input): model
    update: (message: message) => (model: model) => model
    view(model: model): VirtualDomTree<message>
    container: HTMLElement
}

interface State<model, message> {
    commitedVirtualDomTree: VirtualDomTree<message>
    diffWork?: DiffWork<any, any>
    diffWorkResult?: DiffWorkResult<message>
    hasRequestedAsyncRendering: boolean
    model: model
}

function unsafe_document<input, model, message>({ init, input, update, container, view }: Spec<input, model, message>): void {
    const initialModel: model = init(input)
    const initialVirtualDomTree: VirtualDomTree<message> = view(initialModel)
    const outputHandlers = OutputHandlersList.mkNil(unsafe_dispatchMessage)
    const environment: DiffWorkEnvironment<message, message> = {
        scheduler: mkScheduler(),
        unsafe_dispatchDiffWork,
        unsafe_finishDiffWork,
    }

    let state: State<model, message> = {
        commitedVirtualDomTree: initialVirtualDomTree,
        diffWork: undefined,
        diffWorkResult: undefined,
        hasRequestedAsyncRendering: false,
        model: initialModel,
    }

    function unsafe_dispatchMessage(message: message): void {
        const previousModel = state.model
        const nextModel = update(message)(previousModel)

        if (previousModel === nextModel) return

        state.model = nextModel

        if (state.hasRequestedAsyncRendering) return

        window.setImmediate(unsafe_render)
        state.hasRequestedAsyncRendering = true
    }

    function unsafe_render(): void {
        const nextVirtualDomTree = view(state.model)
        const initialDiffWork = mkRootDiffWork(state.commitedVirtualDomTree, nextVirtualDomTree)

        state.hasRequestedAsyncRendering = false

        unsafe_uncurried_performDiffWork(initialDiffWork, environment)
    }

    function unsafe_dispatchDiffWork(diffWork: DiffWork<any, any>): void {
        const hasRequestedAsyncDiffWorkPerformance = state.diffWork !== undefined

        state.diffWork = diffWork

        if (hasRequestedAsyncDiffWorkPerformance) return

        window.setImmediate(unsafe_diff)
    }

    function unsafe_diff() {
        const diffWork = state.diffWork!

        state.diffWork = undefined

        unsafe_uncurried_performDiffWork(diffWork, environment)
    }

    function unsafe_finishDiffWork(diffWorkResult: DiffWorkResult<message>): void {
        const hasRequestedAsyncCommitting = state.diffWorkResult !== undefined

        state.diffWorkResult = diffWorkResult

        if (hasRequestedAsyncCommitting) return

        requestAnimationFrame(unsafe_commit)
    }

    function unsafe_commit() {
        if (state.diffWorkResult === undefined) {
            // ToDo: This is a serious bug. Should be reported.
            throw '### INVARIANT ###'
        }

        const patchTree = state.diffWorkResult.rootPatchTree

        state.commitedVirtualDomTree = state.diffWorkResult.rootVNode
        state.diffWorkResult = undefined

        unsafe_uncurried_applyPatchTree(container, patchTree)
    }

    requestAnimationFrame(() => unsafe_uncurried_mount(container, outputHandlers, initialVirtualDomTree))
}

interface Document {
    <input, model, message>(spec: Spec<input, model, message>): Effect<Unit>
}

export const document: Document = spec => {
    return () => unsafe_document(spec)
}
