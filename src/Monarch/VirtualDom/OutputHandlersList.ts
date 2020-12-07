/**
 * Output handlers list ADT
 */
export type OutputHandlersList = OutputHandlersList.Nil | OutputHandlersList.Cons

export namespace OutputHandlersList {
    // SUM TYPE: Nil

    /**
     * `Nil` type constructor
     */
    export type Nil = (message: any) => void
    export function mkNil<message>(dispatchMessage: (message: message) => Effect<Unit>) {
        return (message: message) => dispatchMessage(message)()
    }

    // SUM TYPE: Cons

    /**
     * `Cons` type constructor
     */
    export interface Cons {
        value: Array<Function> | Function
        next: OutputHandlersList
    }
}

export const nil = OutputHandlersList.mkNil
