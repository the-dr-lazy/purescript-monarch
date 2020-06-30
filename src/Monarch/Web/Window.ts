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
  (id: Int): Effect<Unti>
}

// prettier-ignore
export const _cancelAnimationFrame: _CancelAnimationFrame = id =>
  () => window.cancelAnimationFrame(id)

interface _RequestIdleCallback {
  (n: Int): (f: Effect<Unit>) => Effect<Unit>
}

// prettier-ignore
export const _requestIdleCallback: _RequestIdleCallback = n => f =>
  () => window.requestIdleCallback(f, n !== 0 ? { n } : undefined)

interface _CancelIdleCallback {
  (id: Int): Effect<Unit>
}

// prettier-ignore
export const _cancelIdleCallback: _CancelIdleCallback = id =>
  () => window.cancelIdleCallback(id)
