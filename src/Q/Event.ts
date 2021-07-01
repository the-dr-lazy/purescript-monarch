import * as ADT from './Event/ADT'
import { Scheduler } from './Scehduler'

/**
 * Disjoint union tags for `Event` type
 */
export const enum Tag {
    Empty,
    Map,
    MapTo,
    Never,
    Producer,
}

/**
 * Event ADT
 */
export type Event<a>
    = ADT.Empty
    | ADT.Map<any, a>
    | ADT.MapTo<a>
    | ADT.Never
    | ADT.Producer<a>

export interface Sink<a> {
    next(a: a): void
    error(error: undefined): void
    end(): void
}

export interface Eventish<a> {
    subscribe(sink: Sink<a>, scheduler: Scheduler): void
}

export function uncurried_subscribe<a>(scheduler: Scheduler, source: Event<a>, sink: Sink<a>): void {
    if (source.tag === Tag.Never) return

    return source.subscribe(sink, scheduler)
}
