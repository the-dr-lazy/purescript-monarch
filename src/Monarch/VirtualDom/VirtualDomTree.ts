/**
 * Virtual DOM tree algebraic data type
 */
export type VirtualDomTree<message> =
  | VirtualDomTree.Text
  | VirtualDomTree.Element<message>
  | VirtualDomTree.Tagger // TODO
  | VirtualDomTree.Suspense // TODO: cache async node
  | VirtualDomTree.Thunk // TODO: evaluate given thunk on refrence change
  | VirtualDomTree.Async // TODO: subscribe to asynchronous virtual dom tree
  | VirtualDomTree.Fragment // TODO: render subtrees as children of parent node
  | VirtualDomTree.OffScreen // TODO: evaluate subtree on browser's idles periods

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

  // TODO

  export interface Tagger {}
  export interface Suspense {}
  export interface Thunk {}
  export interface Async {}
  export interface Fragment {}
  export interface OffScreen {}
}
