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
import {
    DiffWorkEnvironment,
    DiffWork,
    DiffWorkResult,
    mkRootDiffWork,
    unsafe_uncurried_performDiffWork,
} from 'monarch/Monarch/VirtualDom/DiffWork'
import { mkScheduler } from 'monarch/Monarch/Scheduler'

interface DispatchMessage<message> {
    (message: message): Effect<Unit>
}

interface DispatchOutput<output> {
    (output: output): Effect<Unit>
}

type Run<effects, a> = unknown

// prettier-ignore
type MkCommandRunner<message, model, output, effects, a> =
  (environment: {
      command: (message: message) => (model: model) => Run<effects, a>,
      interpreter: (command: Run<effects, a>) => Run<any, Unit>,
      dispatchMessage: DispatchMessage<message>,
      dispatchOutput: DispatchOutput<output>
  })
  => (input: { model: model, message: message })
  => Effect<Unit>

interface Spec<input, model, message, output, effects, a> {
    input: input
    init(input: input): model
    update: (message: message) => (model: model) => model
    view(model: model): VirtualDomTree<message>
    container: HTMLElement
    command: (message: message) => (model: model) => Run<effects, a>
    interpreter(command: Run<effects, a>): Run<any, Unit>
    mkCommandRunner: MkCommandRunner<message, model, output, effects, a>
    onOutput(output: output): Effect<Unit>
}

interface State<model, message> {
    /**
     * The virtual DOM tree that has been committed into the DOM tree.
     *
     * @remarks
     *
     * Mutation cases:
     *
     * - When the `PatchTree` has been applied should become
     *   the `VirtualDomTree` that is associated with the `PatchTree` in the `DiffWorkResult`.
     *
     */
    committedVirtualDomTree: VirtualDomTree<message>

    /**
     * The next `DiffWork` that should perform in the next loop.
     *
     * @remarks
     *
     * Mutation cases:
     *
     * - When a new `DiffWork` has been dispatched should mutate to it.
     * - When the `DiffWork` started should flush to `undefined`.
     *
     * This state predicates whether an async callback for performing `DiffWork` has been requested or not.
     *
     * - `undefined`: There is no requested async callback for performing a `DiffWork`.
     * - `DiffWork<message, message>`: An async callback for performing the `DiffWork` has been requested.
     */
    diffWork?: DiffWork<message, message>

    /**
     * Result of a finished diff process that should be applied in the next rAF.
     *
     * @remarks
     *
     * Mutation cases:
     *
     * - When a diff process has been finished should store result of it.
     * - When the `PathTree` has been applied.
     *
     * This state predicated whether an async callback for applying the `PatchTree` has been requested or not.
     *
     * - `undefined`: There is no requested async callback for performing a `PatchTree`.
     * - `DiffWorkResult<message>`: An async callback for applying the `PatchTree` has been requested.
     */
    diffWorkResult?: DiffWorkResult<message>

    /**
     * Whether an async callback for rendering next virtual DOM tree has been requested or not.
     *
     * @remakrs
     *
     * Mutation cases:
     *
     * - When an async callback for rendering has been requested it should become `true`.
     * - When there is no async callback for rendering it should flush to `false`.
     */
    hasRequestedAsyncRendering: boolean

    /**
     * Single source of truth of the application.
     *
     * @remarks
     *
     * Note: this state should mutate synchronously.
     *
     * Mutation cases:
     *
     * - When a new `message` has been dispatched.
     *
     */
    model: model
}

function unsafe_document<input, model, message, output, effects, a>({
    init,
    input,
    update,
    command,
    interpreter,
    mkCommandRunner,
    container,
    view,
    onOutput,
}: Spec<input, model, message, output, effects, a>): void {
    const initialModel: model = init(input)
    const initialVirtualDomTree: VirtualDomTree<message> = view(initialModel)
    const outputHandlers: OutputHandlersList = OutputHandlersList.mkNil(unsafe_dispatchMessage)
    const dispatchMessage: DispatchMessage<message> = message => () => unsafe_dispatchMessage(message)
    const dispatchOutput: DispatchOutput<output> = onOutput
    const runCommand = mkCommandRunner({ command, interpreter, dispatchMessage, dispatchOutput })
    const environment: DiffWorkEnvironment<message, message> = {
        scheduler: mkScheduler(),
        unsafe_dispatchDiffWork,
        unsafe_finishDiffWork,
    }

    let state: State<model, message> = {
        committedVirtualDomTree: initialVirtualDomTree,
        diffWork: undefined,
        diffWorkResult: undefined,
        hasRequestedAsyncRendering: false,
        model: initialModel,
    }

    function unsafe_dispatchMessage(message: message): void {
        const previousModel = state.model
        const nextModel = update(message)(previousModel)

        runCommand({ message, model: nextModel })()

        if (previousModel === nextModel) return

        state.model = nextModel

        if (state.hasRequestedAsyncRendering) return

        window.setImmediate(unsafe_render)
        state.hasRequestedAsyncRendering = true
    }

    function unsafe_render(): void {
        const nextVirtualDomTree = view(state.model)
        const initialDiffWork = mkRootDiffWork(state.committedVirtualDomTree, nextVirtualDomTree)

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

        state.committedVirtualDomTree = state.diffWorkResult.rootVNode
        state.diffWorkResult = undefined

        unsafe_uncurried_applyPatchTree(container, patchTree)
    }

    requestAnimationFrame(() => unsafe_uncurried_mount(container, outputHandlers, initialVirtualDomTree))
}

interface Document {
    <input, model, message, output, effects, a>(spec: Spec<input, model, message, output, effects, a>): Effect<Unit>
}

export const document: Document = spec => {
    return () => unsafe_document(spec)
}
