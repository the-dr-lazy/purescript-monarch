/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2021 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

//
// Primitives
//
type Unit = void
type Int = number
type Lazy<a> = () => a

//
// Data Types
//
type Effect<a> = Lazy<a>

interface Tagged<a> {
    tag: a
}

type Nullable<a> = null | a

/**
 * An opaque type for encoding `Run` type of PureScript.
 *
 * Note: the type details are just for tricking the TypeScript compiler.
 * Don't use them. This is an opaque type. You shouldn't know what is going on...
 */
type Run<effects, a> = { tag: Run<effects, a> }

/**
 * An opaque type for encoding `Either` type of PureScript.
 *
 * Note: the type details are just for tricking the TypeScript compiler.
 * Don't use them. This is an opaque type. You shouldn't know what is going on...
 */
type Either<e, a> = { tag: Either<e, a> }
