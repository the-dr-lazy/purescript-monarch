import { Subscribable, Wirable, Event, Tag, Sink } from '../../Event'
import { Scheduler } from '../../Scheduler'

/**
 * `FilterMap` type constructor
 */
export interface FilterMap<a, b> extends Tagged<Tag.FilterMap>, Subscribable<b> {
    source: Wirable<a>
    p: (a: a) => boolean
    f: (a: a) => b
}

/**
 * `FilterMap` subscribe function
 */
function subscribe<a, b>(this: FilterMap<a, b>, scheduler: Scheduler, sink: Sink<b>): void {
    return this.source.subscribe(scheduler, {
        ...sink,
        next: (t, a) => this.p(a) && sink.next(t, this.f(a)),
    })
}

/**
 * `FilterMap` smart data constructor
 */
export function mk<a, b>(p: FilterMap<a, b>['p'], f: FilterMap<a, b>['f'], source: Event<a>): Event<b> {
    // Note [Plus Annihilation Axiom]
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // f <$> empty = empty
    if (source.tag === Tag.Empty || source.tag === Tag.Never) return source

    return { tag: Tag.Filter, p, f, source, subscribe }
}
