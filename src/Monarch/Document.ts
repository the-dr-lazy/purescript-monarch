import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'
import { VirtualDomTree } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import { PatchTree, unsafe_uncurried_applyPatchTree } from 'monarch/Monarch/VirtualDom/PatchTree'
import { DiffWork, mkRootDiffWork, unsafe_uncurried_mount, unsafe_uncurried_performDiffWork } from 'monarch/Monarch/VirtualDom'
import { mkScheduler } from 'monarch/Monarch/Scheduler'
import * as asap from 'asap'
import 'setimmediate'

interface Spec<input, model, message> {
    input: input
    init(input: input): model
    update: (message: message) => (model: model) => model
    view(model: model): VirtualDomTree<message>
    container: HTMLElement
}

interface DocumentState<model, message> {
    model: model
    commitedVirtualDomTree: VirtualDomTree<message>
    diffWork?: DiffWork<any, any>
    diffWorkResult: DiffWorkResult<message>
    hasRequestedAsyncRendering: boolean
}

interface DiffWorkResult<message> {
    rootVNode?: VirtualDomTree<message>
    rootPatchTree?: PatchTree
}

function unsafe_document<input, model, message>({ init, input, update, container, view }: Spec<input, model, message>): void {
    const initialModel = init(input)
    const initialVirtualDomTree = view(initialModel)
    const outputHandlers = OutputHandlersList.mkNil(dispatchMessage)
    const scheduler = mkScheduler()
    const environment = { scheduler, dispatchDiffWork, finishDiffWork }

    let state: DocumentState<model, message> = {
        model: initialModel,
        commitedVirtualDomTree: initialVirtualDomTree,
        diffWorkResult: {},
        hasRequestedAsyncRendering: false,
    }

    function dispatchMessage(message: message): void {
        const previousModel = state.model
        const nextModel = update(message)(previousModel)

        if (previousModel === nextModel) return

        state.model = nextModel

        if (!state.hasRequestedAsyncRendering) {
            state.hasRequestedAsyncRendering = requestAsap(render)
        }
    }

    function render() {
        const nextVirtualDomTree = view(state.model)
        const initialDiffWork = mkRootDiffWork(state.commitedVirtualDomTree, nextVirtualDomTree)

        state.hasRequestedAsyncRendering = false

        dispatchDiffWork(initialDiffWork)
    }

    function dispatchDiffWork(nextDiffWork: DiffWork<any, any>): void {
        const hasRequestedAsyncDiffWorkPerformance = state.diffWork !== undefined
        state.diffWork = nextDiffWork

        if (hasRequestedAsyncDiffWorkPerformance) return

        window.setImmediate(performDiffWork)
    }

    function performDiffWork() {
        const diffWork = state.diffWork!
        state.diffWork = undefined
        unsafe_uncurried_performDiffWork(diffWork, environment)
    }

    function finishDiffWork(newDiffWrokResult: DiffWorkResult<message>): void {
        const hasRequestedAsyncCommitting = state.diffWorkResult.rootPatchTree !== undefined
        state.diffWorkResult = newDiffWrokResult

        if (hasRequestedAsyncCommitting) return

        requestAnimationFrame(commit)
    }

    function commit() {
        const patchTree = state.diffWorkResult.rootPatchTree!
        state.commitedVirtualDomTree = state.diffWorkResult.rootVNode!
        state.diffWorkResult.rootPatchTree = undefined
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

function requestAsap(task: () => void) {
    asap(task)
    return true
}
