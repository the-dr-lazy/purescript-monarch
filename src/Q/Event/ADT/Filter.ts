import { Subscribable, Wirable, Event, Tag, Sink } from 'monarch/Q/Event'
import { Scheduler } from 'monarch/Q/Scheduler'

/**
 * `Filter` type constructor
 */
export interface Filter<a> extends Tagged<Tag.Filter>, Subscribable<a> {
    source: Wirable<a>
    p: (a: a) => boolean
}

/**
 * `Filter` subscribe function
 */
function subscribe<a>(this: Filter<a>, scheduler: Scheduler, sink: Sink<a>): void {
    return this.source.subscribe(scheduler, {
        next: (t, a) => this.p(a) && sink.next(t, a),
        error: sink.error,
        end: sink.end
    })
}

/**
 * `Filter` smart data constructor
 */
export function mk<a>(p: Filter<a>['p'], source: Event<a>): Event<a> {
    switch (source.tag) {
        // Note [Plus Annihilation Axiom]
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // f <$> empty = empty
        case Tag.Empty:
        case Tag.Never: return source

        // ToDo: explain the axiom
        case Tag.Filter: return mk(a => source.p(a) && p(a), source.source)
    }

    return { tag: Tag.Filter, p, source, subscribe }
}
