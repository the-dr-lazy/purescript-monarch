import { Tag, Event, Subscribable, Wirable, Sink } from '../../Event'
import * as EventFunctorMapTo from './FunctorMapTo'
import * as EventFilterMap from './FilterMap'
import { Scheduler } from '../../Scheduler'

/**
 * `FunctorMap` type constructor
 */
export interface FunctorMap<a, b> extends Tagged<Tag.FunctorMap>, Subscribable<b> {
    source: Wirable<a>
    f: (a: a) => b
}

/**
 * `FunctorMap` subscribe function
 */
function subscribe<a, b>(this: FunctorMap<a, b>, scheduler: Scheduler, sink: Sink<b>): void {
    return this.source.subscribe(scheduler, {
        next: (t, a) => sink.next(t, this.f(a)),
        error: sink.error,
        end: sink.end
    })
}

/**
 * `FunctorMap` smart data constructor
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
        case Tag.FunctorMap: {
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
        case Tag.FunctorMapTo: return EventFunctorMapTo.mk(f(source.value), source.source)

        // ToDo: explain the axiom
        case Tag.Filter: return EventFilterMap.mk(source.p, f, source.source)
    }

    return { tag: Tag.FunctorMap, source, f, subscribe }
}
