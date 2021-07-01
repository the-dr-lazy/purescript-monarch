import { Tag, Event, Eventish, Sink, uncurried_subscribe } from '../../Event'
import { Scheduler } from '../../Scehduler'

/**
 * `Map` type constructor
 */
export interface Map<a, b> extends Tagged<Tag.Map>, Eventish<b> {
    source: Event<a>
    f: (a: a) => b
}

/**
 * `Map` subscribe function
 */
function subscribe<a, b>(this: Map<a, b>, sink: Sink<b>, scheduler: Scheduler): void {
    return uncurried_subscribe(scheduler, this.source, {
        ...sink,
        next: a => sink.next(this.f(a)),
    })
}

/**
 * `Map` smart data constructor
 */
export function mk<a, b>(f: (a: a) => b, source: Event<a>): Event<b> {
    if (source.tag === Tag.Empty || source.tag === Tag.Never) return source

    return { tag: Tag.Map, source, f, subscribe }
}
