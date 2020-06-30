import { init } from 'snabbdom'
import { VNode, VNodeData } from 'snabbdom/vnode'
import { classModule } from 'snabbdom/modules/class'
import { propsModule } from 'snabbdom/modules/props'
import { styleModule } from 'snabbdom/modules/style'
import { eventListenersModule } from 'snabbdom/modules/eventlisteners'
import { h as _h } from 'snabbdom/h'
import { unsafePerformEffect } from '../../output/Effect.Unsafe'

type VirtualNode<message> = VNode & {
  listener: any
  dispatch?: Dispatch<message>
  children?: Array<string | VirtualNode<message>>
}

type VirtualNodeData = VNodeData

type Dispatch<message> = (message: message) => Effect<Unit>

const _patch = init([
  classModule,
  propsModule,
  styleModule,
  eventListenersModule,
])

function bindEventListeners<message>(
  dispatch: Dispatch<message>,
  virtualNode: VirtualNode<message>,
): void {
  if (typeof virtualNode === 'string') return

  if (virtualNode.data?.on) {
    Object.entries(virtualNode.data.on).forEach(([key, f]) => {
      function g(...args: unknown[]) {
        unsafePerformEffect(dispatch(f(...args)))
      }

      virtualNode.data!.on![key] = g
    })
  }

  if (virtualNode.children) {
    virtualNode.children.forEach(virtualNode =>
      bindEventListeners(dispatch, virtualNode),
    )
  }
}

// prettier-ignore
interface Mount {
  <message>(dispatch: Dispatch<message>): (element: HTMLElement) => (virtualNode: VirtualNode<message>) => Effect<void>
}

// prettier-ignore
export const mount: Mount = dispatch => element => virtualNode =>
  () => (bindEventListeners(dispatch, virtualNode), _patch(element, virtualNode))

// prettier-ignore
interface Patch {
  <message>(dispatch: Dispatch<message>): (previousVirtualNode: VirtualNode<message>) => (nextVirtualNode: VirtualNode<message>) => Effect<void>
}

// prettier-ignore
export const patch: Patch = dispatch => previousVirtualNode => nextVirtualNode =>
  () => (bindEventListeners(dispatch, nextVirtualNode), _patch(previousVirtualNode, nextVirtualNode))

// prettier-ignore
interface H {
  (selector: string): <message>(data: VirtualNodeData) => (children: VirtualNode<message>[]) => VirtualNode<message>
}

// prettier-ignore
export const h: H = selector => data => children =>
  <any>_h(selector, data, children)
