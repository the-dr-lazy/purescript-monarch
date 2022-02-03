/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import 'monarch/polyfills'
import '@webcomponents/custom-elements'
import '@webcomponents/custom-elements/src/native-shim'
import { Application, MkHoist } from 'monarch/Monarch/Application/Internal'
import { VirtualDomTree } from 'monarch/Monarch/VirtualDom/VirtualDomTree'

declare global {
    interface Element {
        unsafe_bypassPropertyParsing?(flag: boolean): void
    }
}

interface Input {
    committed?: { [key: string]: unknown }
    patch: {
        parseds?: { [key: string]: unknown }
        attributes?: { [key: string]: Nullable<string> }
        properties?: { [key: string]: Nullable<unknown> }
    }
}

interface RequiredAttributeAndPropertyMetadatum {
    optional: false
    fromAttribute: (raw: string) => Either<string, unknown>
    toAttribute: (value: unknown) => string
    fromProperty: (raw: unknown) => Either<string, unknown>
    toProperty: (value: unknown) => unknown
}
interface OptionalAttributeAndPropertyMetadatum {
    optional: true
    fromAttribute: (raw: Maybe<string>) => Either<string, unknown>
    toAttribute: (value: unknown) => Maybe<string>
    fromProperty: (raw: Maybe<unknown>) => Either<string, unknown>
    toProperty: (value: unknown) => Maybe<unknown>
}
interface OptionalPropertyMetadatum {
    optional: true
    fromProperty: (raw: Maybe<unknown>) => Either<string, unknown>
    toProperty: (value: unknown) => Maybe<unknown>
}
interface RequiredPropertyMetadatum {
    optional: false
    fromProperty: (raw: unknown) => Either<string, unknown>
    toProperty: (value: unknown) => unknown
}
type Metadatum =
    | RequiredAttributeAndPropertyMetadatum
    | OptionalAttributeAndPropertyMetadatum
    | OptionalPropertyMetadatum
    | RequiredPropertyMetadatum

interface Metadata {
    [key: string]: Metadatum
}

export interface Spec<model, message, event extends Event, effects> {
    command: (message: message) => (model: model) => Run<effects, Unit>
    interpreter: <a>(command: Run<effects, a>) => Run<any, a>
    maybeToNullable: <a>(maybe: Maybe<a>) => Nullable<a>
    metadata: Metadata
    mkHoist: MkHoist<message, Variant<event>, effects>
    mkInitialModel: (properties: Input['committed']) => Effect<model>
    nothing: Maybe<any>
    nullableToMaybe: <a>(nullable: Nullable<a>) => Maybe<a>
    onFinalize?: message
    onInitialize?: message
    onInputChange?: (properties: Input['committed']) => message
    tagName: string
    unLeft: <e, a>(evalue: Either<e, a>) => Nullable<e>
    unRight: <e, a>(evalue: Either<e, a>) => Nullable<a>
    update: (message: message) => (model: model) => model
    view: (model: model) => VirtualDomTree<message>
}

interface State<model, message, event extends Event, effects> {
    application?: Application<model, message, Variant<event>, effects>
    hasRequestedAsyncInputDelivery: boolean
    input: Input
    isReflectingAttribute: boolean
    shouldBypassPropertyParsing: boolean
}

export function mkCustomElement<model, message, event extends Event, effects>(
    spec: Spec<model, message, event, effects>,
): CustomElementConstructor {
    const { mkInitialModel, onInputChange, nothing, maybeToNullable, nullableToMaybe } = spec

    const metadata = Object.entries(spec.metadata)
    const attributes = metadata.reduce(
        (attributes, [name, metadata]) => ('fromAttribute' in metadata && attributes.push(name), attributes),
        <Array<string>>[],
    )

    const unsafe_throwEither = window.__MONARCH_UNSAFE_STATE!.ffi.unsafe_throwEither!

    return class CustomHTMLElement extends HTMLElement {
        public static observedAttributes = attributes

        private _state: State<model, message, event, effects> = {
            input: {
                committed: undefined,
                patch: {},
            },
            hasRequestedAsyncInputDelivery: false,
            application: undefined,
            isReflectingAttribute: false,
            shouldBypassPropertyParsing: false,
        }

        constructor() {
            super()

            this.attachShadow({ mode: 'open' })

            metadata.forEach(([key, metadatum]) =>
                Object.defineProperty(this, key, {
                    get: () => this._getPropertyByKey(key),
                    set: (value: unknown) => {
                        if (!this._unsafe_patchInputByKey(key, false, value)) return

                        if ('toAttribute' in metadatum) {
                            this._state.isReflectingAttribute = true

                            const raw = metadatum.optional
                                ? maybeToNullable(metadatum.toAttribute(value))
                                : metadatum.toAttribute(value)
                            raw === null ? this.removeAttribute(key) : this.setAttribute(key, raw)
                        }
                    },
                    configurable: true,
                    enumerable: true,
                }),
            )
        }

        public connectedCallback() {
            this._unsafe_commitInputPatch()

            metadata.forEach(([key, metadata]) => {
                const value = this._state.input.committed![key]

                if (value !== undefined && value !== null) return
                if (!metadata.optional) throw new Error(`Input ${key} is required`)

                this._unsafe_patchInputByKey(key, false, unsafe_throwEither(metadata.fromProperty(nothing)))
            })

            const initialModel = mkInitialModel(this._state.input.committed)()
            this._state.application = new Application({
                ...spec,
                initialModel,
                container: this.shadowRoot!,
                onOutput: variant => () => this.dispatchEvent(variant.value),
            })
        }

        public disconnectedCallback() {
            this._state.application!.unmount()
        }

        public attributeChangedCallback(key: string, prevRaw: Nullable<string>, nextRaw: Nullable<string>): void {
            if (this._state.isReflectingAttribute) {
                this._state.isReflectingAttribute = false

                return
            }

            /*
             * <element KEY="A">
             *
             * element.setAttribute(KEY, 'A')
             */
            if (prevRaw === nextRaw) return

            this._unsafe_patchInputByKey(key, true, nextRaw)
        }

        public unsafe_bypassPropertyParsing = (flag: boolean): void => {
            this._state.shouldBypassPropertyParsing = flag
        }

        private _getPropertyByKey(key: string): unknown {
            if (
                this._state.input.patch.properties !== undefined &&
                this._state.input.patch.properties[key] !== undefined
            ) {
                return this._state.input.patch.properties[key]
            }

            const metadatum = spec.metadata[key]

            if (this._state.input.patch.parseds !== undefined && this._state.input.patch.parseds[key] !== undefined) {
                return metadatum.toProperty(this._state.input.patch.parseds[key])
            }

            if (
                this._state.input.patch.attributes !== undefined &&
                this._state.input.patch.attributes[key] !== undefined
            ) {
                return metadatum.toProperty(this._parseInputAsAttribute(key, this._state.input.patch.attributes[key]))
            }

            return metadatum.toProperty(this._state.input.committed![key])
        }

        private _unsafe_patchInputByKey(key: string, asAttribute: true, value: Nullable<string>): boolean
        private _unsafe_patchInputByKey(key: string, asAttribute: false, value: unknown): boolean
        private _unsafe_patchInputByKey(key: string, asAttribute: boolean, value: unknown): boolean {
            if (asAttribute && this._state.input.patch.properties !== undefined)
                delete this._state.input.patch.properties[key]
            else if (this._state.input.patch.attributes !== undefined) {
                delete this._state.input.patch.attributes[key]
                if (this._state.shouldBypassPropertyParsing && this._state.input.patch.properties !== undefined)
                    delete this._state.input.patch.properties[key]
            }

            const patch = asAttribute
                ? this._state.input.patch.attributes ?? {}
                : this._state.shouldBypassPropertyParsing
                ? this._state.input.patch.parseds ?? {}
                : this._state.input.patch.properties ?? {}

            if (asAttribute) this._state.input.patch.attributes = <any>patch
            else if (this._state.shouldBypassPropertyParsing) this._state.input.patch.parseds = <any>patch
            else this._state.input.patch.properties = patch

            if (patch[key] === value) return false

            patch[key] = value

            if (
                this._state.application !== undefined &&
                onInputChange !== undefined &&
                !this._state.hasRequestedAsyncInputDelivery
            ) {
                this._state.hasRequestedAsyncInputDelivery = true
                window.requestAsap(this._unsafe_dispatchInputChangeMessage)
            }

            return true
        }

        private _parseInputAsProperty = (key: string, raw: unknown): unknown => {
            const metadatum = <OptionalPropertyMetadatum | RequiredPropertyMetadatum>spec.metadata[key]

            if (!metadatum.optional && (raw === null || raw === undefined)) throw new Error(`Input ${key} is required`)

            return unsafe_throwEither(
                metadatum.optional ? metadatum.fromProperty(nullableToMaybe(raw ?? null)) : metadatum.fromProperty(raw),
            )
        }

        private _parseInputAsAttribute = (key: string, raw: Nullable<string>): unknown => {
            const metadatum = <OptionalAttributeAndPropertyMetadatum | RequiredAttributeAndPropertyMetadatum>(
                spec.metadata[key]
            )

            if (!metadatum.optional && (raw === null || raw === undefined))
                throw new Error(`Attribute ${key} is required`)

            return unsafe_throwEither(
                metadatum.optional
                    ? metadatum.fromAttribute(nullableToMaybe(raw ?? null))
                    : metadatum.fromAttribute(raw!),
            )
        }

        private _unsafe_commitInputPatch = (): boolean => {
            let changed = false

            if (
                this._state.input.patch.parseds === undefined &&
                this._state.input.patch.properties === undefined &&
                this._state.input.patch.attributes === undefined
            )
                return changed

            const input: Input['committed'] = {}

            if (this._state.input.patch.parseds !== undefined) {
                Object.entries(this._state.input.patch.parseds).forEach(([key, parsed]) => {
                    if (this._state.input.committed !== undefined && this._state.input.committed![key] === parsed)
                        return

                    changed = true
                    input[key] = parsed
                })

                this._state.input.patch.parseds = undefined
            }

            if (this._state.input.patch.properties !== undefined) {
                Object.entries(this._state.input.patch.properties).forEach(([key, raw]) => {
                    const parsed = this._parseInputAsProperty(key, raw)

                    if (this._state.input.committed !== undefined && this._state.input.committed![key] === parsed)
                        return

                    changed = true
                    input[key] = parsed
                })

                this._state.input.patch.properties = undefined
            }

            if (this._state.input.patch.attributes !== undefined) {
                Object.entries(this._state.input.patch.attributes).forEach(([key, raw]) => {
                    const parsed = this._parseInputAsAttribute(key, raw)

                    if (this._state.input.committed !== undefined && this._state.input.committed![key] === parsed)
                        return

                    changed = true
                    input[key] = parsed
                })

                this._state.input.patch.attributes = undefined
            }

            if (changed) this._state.input.committed = { ...this._state.input.committed, ...input }

            return changed
        }

        private _unsafe_dispatchInputChangeMessage = (): void => {
            this._state.hasRequestedAsyncInputDelivery = false
            if (!this._unsafe_commitInputPatch()) return

            this._state.application!.unsafe_dispatchMessage(onInputChange!(this._state.input.committed))
        }
    }
}
