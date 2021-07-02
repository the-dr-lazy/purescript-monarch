import { Eventish, Event, Tag, Sink, uncurried_subscribe } from 'monarch/Q/Event';
import { Scheduler } from 'monarch/Q/Scheduler';

/**
 * `Filter` type constructor
 */
export interface Filter<a> extends Tagged<Tag.Filter>, Eventish<a> {
    source: Event<a>
    p: (a: a) => boolean
}

/**
 * `Filter` subscribe function
 */
function subscribe<a>(this: Filter<a>, sink: Sink<a>, scheduler: Scheduler): void {
    return uncurried_subscribe(scheduler, this.source, {
        ...sink,
        next: (t, a) => this.p(a) && sink.next(t, a)
    })
}

/**
 * `Filter` smart data constructor
 */
export function mk<a>(p: Filter<a>['p'], source: Event<a>): Event<a> {
    // Note [Plus Annihilation Axiom]
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // f <$> empty = empty
    if (source.tag === Tag.Empty || source.tag === Tag.Never) return source

    return { tag: Tag.Filter, p, source, subscribe }
}
