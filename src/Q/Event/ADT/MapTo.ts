import { Tag, Event, Eventish, Sink, uncurried_subscribe } from '../../Event';
import { Scheduler } from '../../Scehduler';

/**
 * `MapTo` type constructor
 */
export interface MapTo<b> extends Tagged<Tag.MapTo>, Eventish<b> {
    source: Event<any>
    value: b
}

/**
 * `MapTo` subscribe function
 */
function subscribe<b>(this: MapTo<b>, sink: Sink<b>, scheduler: Scheduler): void {
    return uncurried_subscribe(scheduler, this.source, {
        ...sink,
        next: (t) => sink.next(t, this.value),
    });
}

/**
 * `MapTo` smart data constructor
 */
export function mk<a, b>(value: b, source: Event<a>): Event<b> {
    // Note [Plus Annihilation Axiom]
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // f <$> empty = empty
    if (source.tag === Tag.Empty || source.tag === Tag.Never) return source

    // Note [Functor Composition Axiom]
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // map f . map g = map (f . g)
    //
    // This is an inlined derivation of the functor composition
    // axiom for two special cases:
    // map (const x) . map f = map (const x . f)
    //                       = map (const x)
    //
    // map (const x) . map (const y) = map (const x . const y)
    //                               = map (const x)
    while (source.tag === Tag.MapTo || source.tag === Tag.Map) {
        source = source.source
    }

    return { tag: Tag.MapTo, source, value, subscribe }
}
