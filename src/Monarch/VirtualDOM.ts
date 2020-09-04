import { init } from 'snabbdom'
import { VNodeData } from 'snabbdom/vnode'
import { classModule } from 'snabbdom/modules/class'
import { propsModule } from 'snabbdom/modules/props'
import { styleModule } from 'snabbdom/modules/style'
import { eventListenersModule } from 'snabbdom/modules/eventlisteners'
import { h as _h } from 'snabbdom/h'

type VirtualNode<message> = {
    f?: <a>(a: a) => message
    sel: string
    listener: any
    children?: Array<string | VirtualNode<message>>
    data?: VirtualNodeSpec<message>
}

type TransformedVirtualNode<message> = {
    f?: <a>(a: a) => message
    sel: string
    listener: any
    children?: Array<string | VirtualNode<message>>
    data?: TransformedVirtualNodeSpec<message>
}

type VirtualNodeProps = Record<string, any>
type VirtualNodeAttrs = Record<string, string | number | boolean>
type VirtualNodeStyle = Record<string, string> & {
    delayed?: Record<string, string>
    remove?: Record<string, string>
}
type VirtualNodeEvent<message> = Record<string, (event: Event) => message>
type VirtualNodeHooks<message> = Record<string, (...args: any[]) => message>

type TransformedVirtualNodeSpec<message> = {
    key?: string | number | boolean
    props?: VirtualNodeProps
    attrs?: VirtualNodeAttrs
    style?: VirtualNodeStyle
    on?: VirtualNodeEvent<message>
}

type VirtualNodeSpec<message> = {
    [key: string]: any
    props?: VirtualNodeProps
    hooks?: VirtualNodeHooks<message>
}

// prettier-ignore
function unsafe_uncurried_virtualNodeMap<b, c>(g: (b: b) => c, virtualNode: string | VirtualNode<b>) {
  if (typeof virtualNode === 'string') return

  const f = virtualNode.f

  virtualNode.f = <any>(f ? <a>(a: a) => g(f(a)) : g)
}

// prettier-ignore
function uncurried_virtualNodeMap<b, c>(g: (b: b) => c, virtualNode: string | VirtualNode<b>): string | VirtualNode<c> {
  if (typeof virtualNode === 'string') return <any>virtualNode

  const f = virtualNode.f

  return <VirtualNode<c>>{
    ...virtualNode,
    f: f ? <a>(a: a) => g(f(a)) : g,
  }
}

// prettier-ignore
interface VirtualNodeMap {
  <a, b>(f: (a: a) => b): (x: string | VirtualNode<a>) => string | VirtualNode<b>
}

// prettier-ignore
export const virtualNodeMap: VirtualNodeMap = f => virtualNode => uncurried_virtualNodeMap(f, virtualNode)

type Dispatch<message> = (message: message) => Effect<Unit>

const outputPrefix = 'on'

function unsafe_uncurried_transform<message>(
    dispatch: Dispatch<message>,
    virtualNode: VirtualNode<message>,
): virtualNode is TransformedVirtualNode<message> {
    unsafe_uncurried_virtualNodeMap(dispatch, virtualNode)

    if (virtualNode.data) {
        const attributes: Record<string, any> = {}
        const outputs: Record<string, (event: Event) => void> = {}

        for (const key in virtualNode.data) {
            if (key === 'hooks' || key === 'props') continue

            if (key.startsWith(outputPrefix)) {
                const name = key.substr(outputPrefix.length).toLowerCase()

                const f = virtualNode.f!
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
            const f = virtualNode.f!
            const g = virtualNode.data.hooks[name]

            virtualNode.data.hooks[name] = (...a) => f(g(...a))()
        }
    }

    if (virtualNode.children) {
        virtualNode.children.forEach(child => unsafe_uncurried_transform(<any>virtualNode.f!, child))
    }

    return false
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
