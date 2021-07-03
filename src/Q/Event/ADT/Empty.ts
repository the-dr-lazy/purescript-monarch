import { Tag, Sink } from '../../Event';
import { Scheduler } from '../../Scheduler';

/**
 * `Empty` type constructor
 */
export interface Empty extends Tagged<Tag.Empty> {
    subscribe<a>(sink: Sink<a>, scheduler: Scheduler): void
}

/**
 * `Empty` subscribe function
 */
function subscribe<a>(_sink: Sink<a>, _scheduler: Scheduler): void {
    // ToDo: call the `sink.end` at 0.
}

/**
 * `Empty` data constructor
 */
export const empty: Empty = {
    tag: Tag.Empty,
    subscribe
}
