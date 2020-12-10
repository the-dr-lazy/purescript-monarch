/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <thebrodmann@protonmail.com>
 * Copyright  : (c) 2020 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

export type OutputHandlersList = OutputHandlersList.Nil | OutputHandlersList.Cons

export namespace OutputHandlersList {
    // SUM TYPE: Nil

    /**
     * `Nil` type constructor
     */
    export type Nil = (message: any) => void
    export function mkNil<message>(dispatchMessage: (message: message) => Effect<Unit>) {
        return (message: message) => dispatchMessage(message)()
    }

    // SUM TYPE: Cons

    /**
     * `Cons` type constructor
     */
    export interface Cons {
        value: Array<Function> | Function
        next: OutputHandlersList
    }
}

export const nil = OutputHandlersList.mkNil
