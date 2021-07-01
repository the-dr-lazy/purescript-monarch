export type Sink<a> = {
    next(a: a): void
    error(error: undefined): void
    end(): void
}

export interface Eventish<a> {
    subscribe?(sink: Sink<a>, scheduler: Scheduler): void
}

/**
 * Event ADT
 */
export type Event<a>
    = Event.Empty
    | Event.Never
    | Event.Producer<a>
    | Event.Map<any, a>
    | Event.MapTo<a>

export namespace Event {
    /**
     * Disjoint union tags for `Event` type
     */
    const enum Tag {
        Empty,
        Never,
        Producer,
        Map,
        MapTo,
    }

    // SUM TYPE: Empty

    /**
     * `Empty` tag
     *
     * Use it for patter matching.
     */
    export const Empty = Tag.Empty
    /**
     * `Empty` type constructor
     */
    export interface Empty extends Tagged<typeof Empty> { }
    /**
     * `Empty` data constructor
     */
    export const empty = { tag: Empty }

    // SUM TYPE: Never

    /**
     * `Never` tag
     *
     * Use it for patter matching.
     */
    export const Never = Tag.Never
    /**
     * `Never` type constructor
     */
    export interface Never extends Tagged<typeof Never> { }
    /**
     * `Never` data constructor
     */
    export const never = { tag: Never }

    // SUM TYPE: Producer

    /**
     * `Producer` tag
     *
     * Use it for pattern matching.
     */
    export const Producer = Tag.Producer
    /**
     * `Producer` type constructor
     */
    export interface Producer<a> extends Tagged<typeof Producer> {
        subscribe(sink: Sink<a>, scheduler: Scheduler): void
    }
    /**
     * `Producer` smart data constructor
     */
    export function mkProducer<a>(subscribe: Producer<a>['subscribe']): Producer<a> {
        return { tag: Producer, subscribe }
    }

    // SUM TYPE: Map

    /**
     * `Map` tag
     *
     * Use it for pattern matching.
     */
    export const Map = Tag.Map
    /**
     * `Map` type constructor
     */
    export interface Map<a, b> extends Tagged<typeof Map>, Eventish<b> {
        source: Event<a>
        f: (a: a) => b
    }
    /**
     * `Map` smart data constructor
     */
    export function mkMap<a, b>(f: (a: a) => b, source: Event<a>): Event<b> {
        if (source.tag === Tag.Empty || source.tag === Tag.Never) return source

        return { tag: Map, source, f }
    }

    // SUM TYPE: MapTo

    /**
     * `MapTo` tag
     *
     * Use it for pattern matching.
     */
    export const MapTo = Tag.MapTo
    /**
     * `MapTo` type constructor
     */
    export interface MapTo<b> extends Tagged<typeof MapTo>, Eventish<b> {
        source: Event<any>
        value: b
    }
    /**
     * `MapTo` smart data constructor
     */
    export function mkMapTo<a, b>(value: b, source: Event<a>): Event<b> {
        if (source.tag === Tag.Empty || source.tag === Tag.Never) return source

        while (source.tag === Tag.MapTo || source.tag === Tag.Map) {
            source = source.source
        }

        return { tag: MapTo, source, value }
    }
}
