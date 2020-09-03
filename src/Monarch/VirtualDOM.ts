/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
 * Copyright  : (c) 2020 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

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
function unsafe_uncurried_virtualNodeMap<a, b>(f: (a: a) => b, virtualNode: string | VirtualNode<a>) {
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
function uncurried_virtualNodeMap<a, b>(f: (a: a) => b, virtualNode: string | VirtualNode<a>): string | VirtualNode<b> {
  if (typeof virtualNode === 'string') return <any>virtualNode

  let on: VirtualNodeEvent<b> = {}

  if (virtualNode.data?.on) {
    for (const key in virtualNode.data.on) {
      const g = virtualNode.data!.on![key]

      on[key] = (event: Event) => f(g(event))
    }
  }

  let children: Array<string | VirtualNode<b>> | undefined = undefined

  if (virtualNode.children) {
    children = virtualNode.children.map(child => uncurried_virtualNodeMap(f, child))
  }

  return <VirtualNode<b>>{
    ...virtualNode,
    children,
    data: { ...virtualNode.data!, on },
  }
}

// prettier-ignore
interface VirtualNodeMap {
  <a, b>(f: (a: a) => b): (x: string | VirtualNode<a>) => string | VirtualNode<b>
}

// prettier-ignore
export const virtualNodeMap: VirtualNodeMap = f => virtualNode => uncurried_virtualNodeMap(f, virtualNode)

type Dispatch<message> = (message: message) => Effect<Unit>

function unsafe_bindEventListeners<message>(
  dispatch: Dispatch<message>,
  virtualNode: string | VirtualNode<message>,
): void {
  unsafe_uncurried_virtualNodeMap(message => dispatch(message)(), virtualNode)
}

const _patch = init([classModule, propsModule, styleModule, eventListenersModule])

// prettier-ignore
interface Mount {
  <message>(dispatch: Dispatch<message>): (element: HTMLElement) => (virtualNode: VirtualNode<message>) => Effect<void>
}

// prettier-ignore
export const mount: Mount = dispatch => element => virtualNode =>
  () => (unsafe_bindEventListeners(dispatch, virtualNode), _patch(element, <any>virtualNode))

// prettier-ignore
interface Patch {
  <message>(dispatch: Dispatch<message>): (previousVirtualNode: VirtualNode<message>) => (nextVirtualNode: VirtualNode<message>) => Effect<void>
}

// prettier-ignore
export const patch: Patch = dispatch => previousVirtualNode => nextVirtualNode =>
  () => (unsafe_bindEventListeners(dispatch, nextVirtualNode), _patch(<any>previousVirtualNode, <any>nextVirtualNode))

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
