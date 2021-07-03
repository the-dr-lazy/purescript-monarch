import { Tag, Event, Subscribable, Sink, Wirable } from '../../Event'
import { Scheduler } from '../../Scheduler'

/**
 * `MapTo` type constructor
 */
export interface MapTo<b> extends Tagged<Tag.MapTo>, Subscribable<b> {
    source: Wirable<any>
    value: b
}

/**
 * `MapTo` subscribe function
 */
function subscribe<b>(this: MapTo<b>, scheduler: Scheduler, sink: Sink<b>): void {
    return this.source.subscribe(scheduler, {
        ...sink,
        next: t => sink.next(t, this.value),
    })
}

/**
 * `MapTo` smart data constructor
 */
export function mk<a, b>(value: b, source: Event<a>): Event<b> {
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
        //
        // This is an inlined derivation of the functor composition
        // axiom for two special cases:
        // map (const x) . map f = map (const x . f)
        //                       = map (const x)
        //
        case Tag.Map:
        // map (const x) . map (const y) = map (const x . const y)
        //                               = map (const x)
        case Tag.MapTo:
            source = source.source
            break
    }

    return { tag: Tag.MapTo, source, value, subscribe }
}
