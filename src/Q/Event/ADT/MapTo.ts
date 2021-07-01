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
        next: () => sink.next(this.value),
    });
}

/**
 * `MapTo` smart data constructor
 */
export function mk<a, b>(value: b, source: Event<a>): Event<b> {
    if (source.tag === Tag.Empty || source.tag === Tag.Never) return source

    while (source.tag === Tag.MapTo || source.tag === Tag.Map) {
        source = source.source
    }

    return { tag: Tag.MapTo, source, value, subscribe }
}
