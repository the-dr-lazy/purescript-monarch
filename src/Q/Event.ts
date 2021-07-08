import * as ADT from './Event/ADT'
import { Time, Scheduler } from './Scheduler'

/**
 * Disjoint union tags for `Event` type
 */
export const enum Tag {
    Empty,
    Filter,
    FilterMap,
    FunctorMap,
    FunctorMapTo,
    Never,
    Producer,
}

/**
 * Event ADT
 */
export type Event<a>
    = ADT.Empty
    | ADT.Filter<a>
    | ADT.FilterMap<any, a>
    | ADT.FunctorMap<any, a>
    | ADT.FunctorMapTo<a>
    | ADT.Never
    | ADT.Producer<a>

export type Wirable<a> = Exclude<Event<a>, ADT.Empty | ADT.Never>

export interface Subscribable<a> {
    subscribe(scheduler: Scheduler, sink: Sink<a>): void
}

export interface Sink<a> {
    next?(t: Time, a: a): void
    error?(t: Time, error: undefined): void
    end?(t: Time): void
}
