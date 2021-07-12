import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'
import { VirtualDomTree } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import { PatchTree, unsafe_uncurried_applyPatchTree } from 'monarch/Monarch/VirtualDom/PatchTree'
import { DiffWork, unsafe_uncurried_mount, mkDiffWork, unsafe_uncurried_performDiffWork } from 'monarch/Monarch/VirtualDom'
import { mkScheduler } from 'monarch/Monarch/Scheduler'
import { asap } from 'asap/browser-asap'
import 'setimmediate'

interface Spec<input, model, message> {
    input: input
    init(input: input): model
    update: (message: message) => (model: model) => model
    view(model: model): VirtualDomTree<message>
    container: HTMLElement
}

interface FinishDiffWorkSpec<message> {
    rootVNode: VirtualDomTree<message>
    rootPatchTree: PatchTree
}

function unsafe_document<input, model, message>({ init, input, update, container, view }: Spec<input, model, message>): void {
    const initialModel = init(input)
    const initialVirtualDomTree = view(initialModel)
    const outputHandlers = OutputHandlersList.mkNil(dispatchMessage)
    const scheduler = mkScheduler()
    const environment = { scheduler, dispatchDiffWork, finishDiffWork }

    let model = initialModel
    let commitedVirtualDomTree = initialVirtualDomTree
    let diffWork: DiffWork<any, any> | undefined = undefined
    let patchTree: PatchTree | undefined = undefined

    let hasRequestedAsyncRendering = false
    let hasRequestedAsyncPerformDiffWork = false
    let hasRequestedAsyncCommitting = false

    function dispatchMessage(message: message): void {
        const previousModel = model
        const nextModel = update(message)(previousModel)

        if (previousModel === nextModel) return

        model = nextModel

        if (!hasRequestedAsyncRendering) {
            hasRequestedAsyncRendering = requestAsap(render)
        }
    }

    function render() {
        const nextVirtualDomTree = view(model)
        const initialDiffWork = mkDiffWork(commitedVirtualDomTree, nextVirtualDomTree)

        hasRequestedAsyncRendering = false

        dispatchDiffWork(initialDiffWork)
    }

    function dispatchDiffWork(nextDiffWork: DiffWork<any, any>): void {
        diffWork = nextDiffWork

        if (!hasRequestedAsyncPerformDiffWork) {
            hasRequestedAsyncPerformDiffWork = true

            window.setImmediate(performDiffWork)
        }
    }

    function performDiffWork() {
        unsafe_uncurried_performDiffWork(diffWork!, environment)
    }

    function finishDiffWork({ rootVNode, rootPatchTree }: FinishDiffWorkSpec<message>): void {
        patchTree = rootPatchTree
        hasRequestedAsyncPerformDiffWork = false

        if (!hasRequestedAsyncCommitting) {
            hasRequestedAsyncCommitting = true

            requestAnimationFrame(() => {
                unsafe_uncurried_applyPatchTree(container, patchTree!)
                commitedVirtualDomTree = rootVNode
                hasRequestedAsyncCommitting = false
            })
        }
    }

    requestAnimationFrame(() => unsafe_uncurried_mount(container, outputHandlers, initialVirtualDomTree))
}

export function document<input, model, message>(spec: Spec<input, model, message>): Effect<Unit> {
    return () => unsafe_document(spec)
}

function requestAsap(task: () => void) {
    asap(task)
    return true
}
