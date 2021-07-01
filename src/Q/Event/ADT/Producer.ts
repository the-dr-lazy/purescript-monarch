import { Tag, Eventish } from '../../Event';

/**
 * `Producer` type constructor
 */
export interface Producer<a> extends Tagged<Tag.Producer>, Eventish<a> { }

/**
 * `Producer` smart data constructor
 */
export function mk<a>(subscribe: Producer<a>['subscribe']): Producer<a> {
    return { tag: Tag.Producer, subscribe }
}
