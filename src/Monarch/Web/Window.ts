/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2021 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import 'setimmediate'

interface SetTimeout {
    (n: Int): (f: Effect<Unit>) => Effect<Int>
}

export const setTimeout: SetTimeout = n => f => () => window.setTimeout(f, n)

interface ClearTimeout {
    (id: Int): Effect<Unit>
}

export const clearTimeout: ClearTimeout = id => () => window.clearTimeout(id)

interface SetInterval {
    (n: Int): (f: Effect<Unit>) => Effect<Int>
}

export const setInterval: SetInterval = n => f => () => window.setInterval(f, n)

interface ClearInterval {
    (id: Int): Effect<Unit>
}

export const clearInterval: ClearInterval = id => () => window.clearInterval(id)

interface _RequestAnimationFrame {
    (f: Effect<Unit>): Effect<Unit>
}

// prettier-ignore
export const _requestAnimationFrame: _RequestAnimationFrame = f =>
  () => window.requestAnimationFrame(f)

interface _CancelAnimationFrame {
    (id: Int): Effect<Unit>
}

// prettier-ignore
export const _cancelAnimationFrame: _CancelAnimationFrame = id =>
  () => window.cancelAnimationFrame(id)

interface _RequestIdleCallback {
    (n: Int): (f: Effect<Unit>) => Effect<Unit>
}

// prettier-ignore
export const _requestIdleCallback: _RequestIdleCallback = timeout => f =>
  () => window.requestIdleCallback(f, { timeout })

interface _CancelIdleCallback {
    (id: Int): Effect<Unit>
}

// prettier-ignore
export const _cancelIdleCallback: _CancelIdleCallback = id =>
  () => window.cancelIdleCallback(id)

//
// Experimental Browser APIs Declarations
//

declare global {
    interface Window extends IdleCallbackProvider {}
}

//
// Request Idle Callback
//
type RequestIdleCallbackOptions = {
    readonly timeout: number
}

type IdleCallbackDeadline = {
    readonly didTimeout: boolean
    readonly timeRemaining: Lazy<Number>
}

// prettier-ignore
type IdleCallbackRequestCallback = (deadline: IdleCallbackDeadline) => void

interface IdleCallbackProvider {
    // prettier-ignore
    requestIdleCallback(callback: IdleCallbackRequestCallback, options?: RequestIdleCallbackOptions): number
    cancelIdleCallback(handle: number): void
}

interface RequestImmediate {
    (f: Effect<Unit>): Effect<Int>
}

// prettier-ignore
export const _requestImmediate: RequestImmediate = f =>
  () => window.setImmediate(f)

interface CancelImmediate {
    (id: Int): Effect<Unit>
}

// prettier-ignore
export const _cancelImmediate: CancelImmediate = id =>
  () => window.clearImmediate(id)
