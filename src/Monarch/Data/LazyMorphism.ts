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
 * Lazy morphism (transformation) ADT
 */
export type Type<raw, evaluated> = Raw<raw> | Evaluated<evaluated>

/**
 * Disjoint union tags for `LazyMorphism` type
 *
 * Note: Don't use the 1x for any other tagged unions.
 */
export enum Tag {
    Raw = 10,
    Evaluated = 11,
}

// SUM TYPE: Raw

interface Raw<raw> {
    tag: Tag.Raw
    value: raw
}

// SUM TYPE: Evaluated

interface Evaluated<evaluated> {
    tag: Tag.Evaluated
    value: evaluated
}

export function mk<raw>(value: raw): Raw<raw> {
    return { tag: Tag.Raw, value }
}

export function unsafe_evaluate<raw, evaluated>(lazy: Type<raw, evaluated>, f: (raw: raw) => evaluated): evaluated {
    if (lazy.tag === Tag.Evaluated) return lazy.value
    ;(<Type<raw, evaluated>>lazy).tag = Tag.Evaluated
    ;(<Type<raw, evaluated>>lazy).value = f(lazy.value)

    return (<any>lazy).value
}
