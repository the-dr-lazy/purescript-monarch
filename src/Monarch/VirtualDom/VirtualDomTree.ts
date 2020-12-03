/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
 * Copyright  : (c) 2020 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

export type VirtualDomTree<message> =
  | VirtualDomTree.Text
  | VirtualDomTree.Element<message>

export namespace VirtualDomTree {
  /**
   * Disjoint union tags for `VirtualDomTree` type
   */
  const enum Tag {
    Text,
    Element,
  }

  // SUM TYPE: Text

  /**
   * `Text` tag
   *
   * Use it for pattern matching
   */
  export const Text = Tag.Text
  /**
   * `Text` type constructor
   */
  export interface Text extends Tagged<typeof Text> {
    text: string
  }
  /**
   * Smart data constructor for `Text` type
   */
  export function mkText(text: string): Text {
    return { tag: Text, text }
  }

  // SUM TYPE: Element

  /**
   * `Element` tag
   *
   * Use it for pattern matching
   */
  export const Element = Tag.Element
  /**
   * `Element` type constructor
   */
  export interface Element<message>
    extends Tagged<typeof Element>,
      Parent<message> {
    ns?: NS
    tagName: TagName
    facts?: Facts
  }
  /**
   * Smart constructor for `Element` type with namespace
   */
  export function mkElementNS<message>(
    ns: NS,
    tagName: TagName,
    facts: Facts,
    children: ReadonlyArray<VirtualDomTree<message>>,
  ): Element<message> {
    return { tag: Element, ns, tagName, facts, children }
  }
  /**
   * Smart constructor for `Element` type without namespace
   */
  export function mkElement<message>(
    tagName: TagName,
    facts: Facts,
    children: ReadonlyArray<VirtualDomTree<message>>,
  ): Element<message> {
    return { tag: Element, tagName, facts, children }
  }

  // SUM TYPE: Tagger

  /**
   * TODO: tag Functor
   */
  export interface Tagger {}

  // SUM TYPE: Async

  /**
   * TODO: subscribe to asynchronous virtual dom tree
   */
  export interface Async {}

  // SUM TYPE: Suspense

  /**
   * TODO: catch async nodes fallback
   */
  export interface Suspense {}

  // SUM TYPE: Thunk

  /**
   * TODO: evaluate the given thunk on reference change
   */
  export interface Thunk {}

  // SUM TYPE: Fragment

  /**
   * TODO: render subtrees as children of parent node
   */
  export interface Fragment {}

  // SUM TYPE: Offscreen

  /**
   * TODO: evaluate subtree on browsers' idle periods
   */
  export interface Offscreen {}

  // INTERNAL

  interface Parent<message> {
    children?: ReadonlyArray<VirtualDomTree<message>>
  }
  type NS =
    | 'http://www.w3.org/1999/xhtml'
    | 'http://www.w3.org/2000/svg'
    | 'http://www.w3.org/1998/Math/MathML'
  type TagName = keyof HTMLElementTagNameMap
  type Facts = {
    [key: string]: any | undefined
    attributes?: Record<string, any>
  }
}
