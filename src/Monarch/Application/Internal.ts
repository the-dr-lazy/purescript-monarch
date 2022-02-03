/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import 'monarch/polyfills'
import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'
import { VirtualDomTree } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import { unsafe_uncurried_mount } from 'monarch/Monarch/VirtualDom'
import {
    DiffWorkEnvironment,
    DiffWork,
    DiffWorkResult,
    mkRootDiffWork,
    unsafe_uncurried_performDiffWork,
} from 'monarch/Monarch/VirtualDom/DiffWork'
import { mkScheduler } from 'monarch/Monarch/Scheduler'
import * as List from 'monarch/Monarch/Data/List'
import { unsafe_applyPatch } from 'monarch/Monarch/VirtualDom/Patch'

export type DispatchMessage<message> = (message: message) => Effect<Unit>
export type DispatchOutput<output> = (output: output) => Effect<Unit>
export type Hoist<effects> = <a>(program: Run<effects, a>) => Effect<Unit>

export interface HoistEnvironment<message, output, effects> {
    dispatchMessage: DispatchMessage<message>
    dispatchOutput: DispatchOutput<output>
    interpreter: <a>(program: Run<effects, a>) => Run<any, a>
}

export type MkHoist<message, output, effects> = (
    environment: HoistEnvironment<message, output, effects>,
) => Hoist<effects>

export interface Spec<model, message, output, effects> {
    command: (message: message) => (model: model) => Run<effects, Unit>
    container: Node
    initialModel: model
    interpreter: <a>(command: Run<effects, a>) => Run<any, a>
    mkHoist: MkHoist<message, output, effects>
    onInitialize?: message
    onFinalize?: message
    onOutput: (output: output) => Effect<Unit>
    update: (message: message) => (model: model) => model
    view: (model: model) => VirtualDomTree<message>
}

interface Environment<message, effects> {
    hoist: Hoist<effects>
    diffWorkEnvironment: DiffWorkEnvironment<message, message>
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

    rootDomNode?: DOM.Node
}

export class Application<model, message, output, effects> {
    private _environment: Environment<message, effects>
    private _state: State<model, message>

    constructor(private _spec: Spec<model, message, output, effects>) {
        const { interpreter, onInitialize, mkHoist, container, initialModel, view, onOutput } = _spec

        this._environment = {
            hoist: mkHoist({
                interpreter,
                dispatchMessage: message => () => this.unsafe_dispatchMessage(message),
                dispatchOutput: onOutput,
            }),

            diffWorkEnvironment: {
                scheduler: mkScheduler(),
                unsafe_dispatchDiffWork: this._unsafe_dispatchDiffWork,
                unsafe_finishDiffWork: this._unsafe_finishDiffWork,
            },
        }

        const outputHandlers: OutputHandlersList = OutputHandlersList.mkNil(this.unsafe_dispatchMessage)

        const initialVirtualDomTree: VirtualDomTree<message> = view(initialModel)

        this._state = {
            committedVirtualDomTree: initialVirtualDomTree,
            diffWork: undefined,
            diffWorkResult: undefined,
            hasRequestedAsyncRendering: false,
            model: initialModel,
        }

        onInitialize && this.unsafe_dispatchMessage(onInitialize)

        requestAnimationFrame(
            () => (this._state.rootDomNode = unsafe_uncurried_mount(container, outputHandlers, initialVirtualDomTree)),
        )
    }

    public unsafe_dispatchMessage = (message: message): void => {
        const { update, command } = this._spec
        const { hoist } = this._environment

        const previousModel = this._state.model
        const nextModel = update(message)(previousModel)

        hoist(command(message)(nextModel))()

        if (previousModel === nextModel) return

        this._state.model = nextModel

        if (this._state.hasRequestedAsyncRendering) return

        window.requestImmediate(this._unsafe_render)
        this._state.hasRequestedAsyncRendering = true
    }

    private _unsafe_render = (): void => {
        const { view } = this._spec
        const { diffWorkEnvironment } = this._environment

        const nextVirtualDomTree = view(this._state.model)
        const initialDiffWork = mkRootDiffWork(
            this._state.committedVirtualDomTree,
            nextVirtualDomTree,
            this._state.rootDomNode!,
        )

        this._state.hasRequestedAsyncRendering = false

        unsafe_uncurried_performDiffWork(initialDiffWork, diffWorkEnvironment)
    }

    private _unsafe_dispatchDiffWork = (diffWork: DiffWork<any, any>): void => {
        const hasRequestedAsyncDiffWorkPerformance = this._state.diffWork !== undefined

        this._state.diffWork = diffWork

        if (hasRequestedAsyncDiffWorkPerformance) return

        window.requestImmediate(this._unsafe_diff)
    }

    private _unsafe_diff = () => {
        const { diffWorkEnvironment } = this._environment

        const diffWork = this._state.diffWork!

        this._state.diffWork = undefined

        unsafe_uncurried_performDiffWork(diffWork, diffWorkEnvironment)
    }

    private _unsafe_finishDiffWork = (diffWorkResult: DiffWorkResult<message>): void => {
        const hasRequestedAsyncCommitting = this._state.diffWorkResult !== undefined

        this._state.diffWorkResult = diffWorkResult

        if (hasRequestedAsyncCommitting) return

        requestAnimationFrame(this._unsafe_commit)
    }

    private _unsafe_commit = () => {
        if (this._state.diffWorkResult === undefined) {
            // ToDo: This is a serious bug. Should be reported.
            throw '### INVARIANT diff ###'
        }

        let patches = this._state.diffWorkResult.patches

        this._state.committedVirtualDomTree = this._state.diffWorkResult.rootVNode
        this._state.diffWorkResult = undefined

        while (patches.tag !== List.Tag.Nil) {
            unsafe_applyPatch(patches.head)

            patches = patches.tail
        }
    }

    public unmount = () => {
        const { onFinalize } = this._spec

        onFinalize && this.unsafe_dispatchMessage(onFinalize)
    }
}
