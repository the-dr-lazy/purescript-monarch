import * as ADT from './Event/ADT'
import { Time, Scheduler } from './Scheduler'

/**
 * Disjoint union tags for `Event` type
 */
export const enum Tag {
    Empty,
    Filter,
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
    | ADT.Filter<a>
    | ADT.Map<any, a>
    | ADT.MapTo<a>
    | ADT.Never
    | ADT.Producer<a>

export interface Sink<a> {
    next(t: Time, a: a): void
    error(t: Time, error: undefined): void
    end(t: Time): void
}

export interface Eventish<a> {
    subscribe(sink: Sink<a>, scheduler: Scheduler): void
}

export function uncurried_subscribe<a>(scheduler: Scheduler, source: Event<a>, sink: Sink<a>): void {
    if (source.tag === Tag.Never) return

    return source.subscribe(sink, scheduler)
}
