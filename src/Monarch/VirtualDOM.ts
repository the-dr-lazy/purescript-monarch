import { init } from 'snabbdom'
import { vnode as _vnode, VNodeData, Key } from 'snabbdom/vnode'
import { classModule } from 'snabbdom/modules/class'
import { propsModule } from 'snabbdom/modules/props'
import { styleModule } from 'snabbdom/modules/style'
import { eventListenersModule } from 'snabbdom/modules/eventlisteners'
import { h as _h } from 'snabbdom/h'

type VirtualNode<message> = {
    sel: string
    key?: Key
    text?: string
    elm?: HTMLElement
    listener?: any
    children?: VirtualNode<message>[]
    data?: VirtualNodeSpec<message>
    f?: <a>(a: a) => message
}

type TransformedVirtualNode = {
    sel: string
    key?: Key
    text?: string
    elm?: HTMLElement
    listener?: any
    children?: TransformedVirtualNode[]
    data?: TransformedVirtualNodeSpec
    f?: <a>(a: a) => Effect<Unit>
}

type VirtualNodeSpec<message> = {
    [key: string]: any
    props?: VirtualNodeProps
    hooks?: VirtualNodeHooks<message>
}

type TransformedVirtualNodeSpec = {
    props?: VirtualNodeProps
    attrs?: VirtualNodeAttrs
    style?: VirtualNodeStyle
    on?: VirtualNodeEvent<void>
    hooks?: VirtualNodeHooks<void>
    key?: Key
}

type VirtualNodeProps = Record<string, any>
type VirtualNodeAttrs = Record<string, string | number | boolean>
type VirtualNodeStyle = Record<string, string> & {
    delayed?: Record<string, string>
    remove?: Record<string, string>
}
type VirtualNodeEvent<message> = Record<string, (event: Event) => message>
type VirtualNodeHooks<message> = Record<string, (...args: any[]) => message>

// prettier-ignore
function unsafe_uncurried_virtualNodeMap<b, c>(g: (b: b) => c, virtualNode: VirtualNode<b>): virtualNode is VirtualNode<b> & VirtualNode<c> {
  const f = virtualNode.f

  virtualNode.f = <any>(f ? <a>(a: a) => g(f(a)) : g)

  return true
}

// prettier-ignore
function uncurried_virtualNodeMap<b, c>(g: (b: b) => c, virtualNode: VirtualNode<b>): VirtualNode<c> {
  const f = virtualNode.f

  return <VirtualNode<c>>{
    ...virtualNode,
    f: f ? <a>(a: a) => g(f(a)) : g,
  }
}

// prettier-ignore
interface VirtualNodeMap {
  <a, b>(f: (a: a) => b): (x: VirtualNode<a>) => VirtualNode<b>
}

// prettier-ignore
export const virtualNodeMap: VirtualNodeMap = f => virtualNode => uncurried_virtualNodeMap(f, virtualNode)

type Dispatch<message> = (message: message) => Effect<Unit>

const outputPrefix = 'on'

function unsafe_uncurried_transform<message>(
    dispatch: Dispatch<message>,
    virtualNode: VirtualNode<message>,
): virtualNode is VirtualNode<message> & TransformedVirtualNode {
    if (!unsafe_uncurried_virtualNodeMap(dispatch, virtualNode)) throw '### UNREACHABLE CODE ###'

    if (virtualNode.data) {
        const attributes: Record<string, any> = {}
        const outputs: Record<string, (event: Event) => void> = {}

        for (const key in virtualNode.data) {
            if (key === 'hooks' || key === 'props') continue

            if (key.startsWith(outputPrefix)) {
                const name = key.substr(outputPrefix.length).toLowerCase()

                const f = <Dispatch<message>>virtualNode.f!
                const g = virtualNode.data[key]

                outputs[name] = a => f(g(a))()

                continue
            }

            attributes[key] = virtualNode.data[key]
        }

        virtualNode.data!.attrs = attributes
        virtualNode.data!.on = outputs
    }

    if (virtualNode.data?.hooks) {
        for (const name in virtualNode.data.hooks) {
            const f = <Dispatch<any>>virtualNode.f!
            const g = virtualNode.data.hooks[name]

            virtualNode.data.hooks[name] = <any>((...a: any[]) => f(g(...a))())
        }

        if (virtualNode.children) {
            virtualNode.children.forEach(child => unsafe_uncurried_transform(<any>virtualNode.f!, child))
        }
    }

    return true
}

const _patch = init([classModule, propsModule, styleModule, eventListenersModule])

// prettier-ignore
interface Mount {
  <message>(dispatch: Dispatch<message>): (element: HTMLElement) => (virtualNode: VirtualNode<message>) => Effect<void>
}

// prettier-ignore
export const mount: Mount = dispatch => element => virtualNode =>
  () => (unsafe_uncurried_transform(dispatch, virtualNode), _patch(element, <any>virtualNode))

// prettier-ignore
interface Patch {
  <message>(dispatch: Dispatch<message>): (previousVirtualNode: VirtualNode<message>) => (nextVirtualNode: VirtualNode<message>) => Effect<void>
}

// prettier-ignore
export const patch: Patch = dispatch => previousVirtualNode => nextVirtualNode =>
  () => (unsafe_uncurried_transform(dispatch, nextVirtualNode), _patch(<any>previousVirtualNode, <any>nextVirtualNode))

interface Unmount {
    <message>(virtualNode: VirtualNode<message>): Effect<Unit>
}

// prettier-ignore
export const unmount: Unmount = virtualNode =>
  () => _patch(<any>virtualNode, _h('!'))

// prettier-ignore
interface H {
  (selector: string): <message>(spec: VirtualNodeSpec<message>) => (children: VirtualNode<message>[]) => VirtualNode<message>
}

// prettier-ignore
export const h: H = selector => spec => children =>
  <any>_h(selector, <VNodeData>spec, <any>children)
