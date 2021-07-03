import { Tag, Event, Subscribable, Wirable, Sink } from '../../Event'
import * as EventMapTo from './MapTo'
import * as EventFilterMap from './FilterMap'
import { Scheduler } from '../../Scheduler'

/**
 * `Map` type constructor
 */
export interface Map<a, b> extends Tagged<Tag.Map>, Subscribable<b> {
    source: Wirable<a>
    f: (a: a) => b
}

/**
 * `Map` subscribe function
 */
function subscribe<a, b>(this: Map<a, b>, scheduler: Scheduler, sink: Sink<b>): void {
    return this.source.subscribe(scheduler, {
        ...sink,
        next: (t, a) => sink.next(t, this.f(a)),
    })
}

/**
 * `Map` smart data constructor
 */
export function mk<a, b>(f: (a: a) => b, source: Event<a>): Event<b> {
    switch (source.tag) {
        // Note [Plus Annihilation Axiom]
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // f <$> empty = empty
        case Tag.Empty:
        case Tag.Never:
            return source

        // Note [Functor Composition Axiom]
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // map f . map g = map (f . g)
        case Tag.Map: {
            const g = source.f

            f = x => f(g(x))
            source = source.source

            break
        }

        // ToDo: explain the axiom
        case Tag.FilterMap: {
            const g = source.f

            f = x => f(g(x))

            return EventFilterMap.mk(source.p, f, source.source)
        }

        // See Note [Functor Composition Axiom]
        // This is an inlined derivation of the functor composition
        // axiom for a special case:
        // map f . map (const x) = map (f . const x)
        //                       = map (const (f x))
        case Tag.MapTo: return EventMapTo.mk(f(source.value), source.source)

        // ToDo: explain the axiom
        case Tag.Filter: return EventFilterMap.mk(source.p, f, source.source)

    }

    return { tag: Tag.Map, source, f, subscribe }
}
