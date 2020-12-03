/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
 * Copyright  : (c) 2020 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

export type OutputHandlerTree = OutputHandlerTree.Root | OutputHandlerTree.Node

export namespace OutputHandlerTree {
    // SUM TYPE: Root

    /**
     * `Root` type constructor
     */
    export interface Root {
        parent: Function
    }

    // SUM TYPE: Node

    /**
     * `Node` type constructor
     */
    export interface Node {
        f: Array<Function> | Function
        parent: OutputHandlerTree
    }
}

// prettier-ignore
interface MkRootOutputHandlerNode {
  (dispatchMessage: (message: any) => Effect<Unit>): OutputHandlerTree.Root
}

// prettier-ignore
export const mkRootOutputHandlerNode: MkRootOutputHandlerNode = dispatchMessage => ({
  parent: (message: any) => dispatchMessage(message)(),
})
