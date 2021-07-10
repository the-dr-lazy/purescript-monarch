/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2021 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

type GetCurrentTime = Effect<number>

export const getCurrentTime: GetCurrentTime = (() => {
    const hasPerformanceNow = typeof performance === 'object' && typeof performance.now === 'function'

    if (hasPerformanceNow) {
        return () => performance.now()
    } else {
        const initialTime = Date.now()

        return () => Date.now() - initialTime
    }
})()

interface Scheduler {
    shouldYieldToBrowser(): boolean
    promoteDeadline(): void
}

export function mkScheduler(): Scheduler {
    let deadline = 0
    return {
        shouldYieldToBrowser: () => getCurrentTime() > deadline,
        promoteDeadline: () => {
            deadline = deadline + 5
        },
    }
}
