/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/**
 * List ADT
 */
export type Type<a> = Nil | Cons<a>

/**
 * Disjoint union tags for `List` type
 *
 * Note: Don't use the 2x for any other tagged unions.
 */
export enum Tag {
    Nil = 20,
    Cons = 21,
}

// SUM TYPE: Nil

export type Nil = { tag: Tag.Nil }
export const nil: Nil = { tag: Tag.Nil }

// SUM TYPE: Cons

export type Cons<a> = { tag: Tag.Cons; head: a; tail: Type<a> }
export function mkCons<a>(head: a, tail: Type<a>): Cons<a> {
    return { tag: Tag.Cons, head, tail }
}
