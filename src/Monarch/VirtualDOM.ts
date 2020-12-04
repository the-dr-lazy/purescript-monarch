import { init } from 'snabbdom'
import { VNodeData } from 'snabbdom/vnode'
import { classModule } from 'snabbdom/modules/class'
import { propsModule } from 'snabbdom/modules/props'
import { styleModule } from 'snabbdom/modules/style'
import { eventListenersModule } from 'snabbdom/modules/eventlisteners'
import { h as _h } from 'snabbdom/h'

type VirtualNode<message> = {
    sel: string
    listener: any
    dispatch?: Dispatch<message>
    children?: Array<string | VirtualNode<message>>
    data?: VirtualNodeSpec<message>
}

type VirtualNodeProps = Record<string, any>
type VirtualNodeAttrs = Record<string, string | number | boolean>
type VirtualNodeStyle = Record<string, string> & {
    delayed?: Record<string, string>
    remove?: Record<string, string>
}
type VirtualNodeEvent<message> = Record<string, (event: Event) => message>

type VirtualNodeSpec<message> = {
    key?: string | number | boolean
    props?: VirtualNodeProps
    attrs?: VirtualNodeAttrs
    style?: VirtualNodeStyle
    on?: VirtualNodeEvent<message>
}

// prettier-ignore
interface VirtualNodeMap {
  <a, b>(f: (a: a) => b): (x: string | VirtualNode<a>) => string | VirtualNode<b>
}

// prettier-ignore
function uncurryVirtualNodeMap<a, b>(f: (a: a) => b, virtualNode: string | VirtualNode<a>) {
  if (typeof virtualNode === 'string') return <any>virtualNode

  if (virtualNode.data?.on) {
    Object.entries(virtualNode.data.on).forEach(([key, g]) => {
      function h(event: Event) {
        return f(g(event))
      }

      virtualNode.data!.on![key] = <any>h
    })
  }

  if (virtualNode.children) {
    virtualNode.children.forEach(child => virtualNodeMap(f)(child))
  }

  return <any>virtualNode
}

// prettier-ignore
export const virtualNodeMap: VirtualNodeMap = f => virtualNode =>
  uncurryVirtualNodeMap(f, virtualNode)

type Dispatch<message> = (message: message) => Effect<Unit>

function bindEventListeners<message>(dispatch: Dispatch<message>, virtualNode: string | VirtualNode<message>) {
    uncurryVirtualNodeMap(message => dispatch(message)(), virtualNode)
}

const _patch = init([classModule, propsModule, styleModule, eventListenersModule])

// prettier-ignore
interface Mount {
  <message>(dispatch: Dispatch<message>): (element: HTMLElement) => (virtualNode: VirtualNode<message>) => Effect<void>
}

// prettier-ignore
export const mount: Mount = dispatch => element => virtualNode =>
  () => (bindEventListeners(dispatch, virtualNode), _patch(element, <any>virtualNode))

// prettier-ignore
interface Patch {
  <message>(dispatch: Dispatch<message>): (previousVirtualNode: VirtualNode<message>) => (nextVirtualNode: VirtualNode<message>) => Effect<void>
}

// prettier-ignore
export const patch: Patch = dispatch => previousVirtualNode => nextVirtualNode =>
  () => (bindEventListeners(dispatch, nextVirtualNode), _patch(<any>previousVirtualNode, <any>nextVirtualNode))

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
