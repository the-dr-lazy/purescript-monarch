/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2022 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { VirtualDomTree } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'

export const attributesKeyName = 'attributes'
export const keyPropertyName = 'key'
export const outputKeyPrefix = 'on'
export const slotNamePropertyName = 'name'
export const defaultSlotName = 'default'

export interface Facts {
    [key: string]: unknown
    [keyPropertyName]?: unknown
    [attributesKeyName]?: { [key: string]: string }
}

type OutputHandler = <a>(event: Event) => a

export interface OrganizedFacts {
    [FactCategory.Attribute]?: { [key: string]: string }
    [FactCategory.Property]?: { [key: string]: unknown }
    [FactCategory.Output]?: { [key: string]: OutputHandler }
}

export enum FactCategory {
    Attribute,
    Property,
    Output,
}

export const organizeFacts = (tagName: string) => (facts: Facts): OrganizedFacts => {
    const organizedFacts: OrganizedFacts = {}

    for (const key in facts) {
        if (key === attributesKeyName) {
            organizedFacts[FactCategory.Attribute] = facts[key]

            continue
        }

        if (tagName === 'slot' && key === slotNamePropertyName && facts[slotNamePropertyName] === defaultSlotName)
            continue

        if (key === keyPropertyName) continue

        if (key.startsWith(outputKeyPrefix)) {
            const outputName = key.substr(outputKeyPrefix.length).toLowerCase()

            organizedFacts[FactCategory.Output] = organizedFacts[FactCategory.Output] || {}
            organizedFacts[FactCategory.Output]![outputName] = <OutputHandler>facts[key]

            continue
        }

        organizedFacts[FactCategory.Property] = organizedFacts[FactCategory.Property] || {}
        organizedFacts[FactCategory.Property]![key] = facts[key]
    }

    return organizedFacts
}

export function unsafe_applyFacts(domElement: Element, diff: OrganizedFacts): void {
    Object.entries(diff).forEach(([category, subDiff]) => {
        switch (+category) {
            case FactCategory.Property:
                return unsafe_applyProperties(domElement, subDiff)
            case FactCategory.Attribute:
                return unsafe_applyAttributes(domElement, subDiff)
            case FactCategory.Output:
                return unsafe_applyOutputs(domElement, subDiff)
        }
    })
}

function unsafe_applyAttributes(domElement: Element, attributes: OrganizedFacts[FactCategory.Attribute]): void {
    for (var key in attributes) {
        const value = attributes[key]

        value !== undefined ? domElement.setAttribute(key, value) : domElement.removeAttribute(key)
    }
}

function unsafe_applyProperties(domElement: Element, properties: OrganizedFacts[FactCategory.Property]): void {
    const supportsPropertyParsingBypassing = domElement.unsafe_bypassPropertyParsing !== undefined

    supportsPropertyParsingBypassing && domElement.unsafe_bypassPropertyParsing!(true)

    for (const key in properties) {
        ;(<any>domElement)[key] = properties[key]
    }

    supportsPropertyParsingBypassing && domElement.unsafe_bypassPropertyParsing!(false)
}

declare global {
    interface Node {
        monarch_outputHandlerInterceptors?: { [name: string]: OutputHandlerInterceptor | undefined }
    }
}

function unsafe_applyOutputs(domElement: Element, outputs: OrganizedFacts[FactCategory.Output]): void {
    const outputHandlerInterceptors = (domElement.monarch_outputHandlerInterceptors =
        domElement.monarch_outputHandlerInterceptors || {})

    for (const name in outputs) {
        var newHandler = outputs[name]
        var oldOutputHandlerInterceptor = outputHandlerInterceptors[name]

        if (!newHandler) {
            domElement.removeEventListener(name, oldOutputHandlerInterceptor!)
            outputHandlerInterceptors[name] = undefined

            continue
        }

        if (oldOutputHandlerInterceptor) {
            oldOutputHandlerInterceptor.handler = newHandler

            continue
        }

        oldOutputHandlerInterceptor = mkOutputHandlerInterceptor(
            newHandler,
            () => domElement.__MONARCH_UNSAFE_OUTPUT_HANDLERS!,
        )
        domElement.addEventListener(name, oldOutputHandlerInterceptor)

        outputHandlerInterceptors[name] = oldOutputHandlerInterceptor
    }
}

interface OutputHandlerInterceptor {
    (event: Event): void
    handler<a>(event: Event): a
}

function mkOutputHandlerInterceptor(
    handler: <a>(event: Event) => a,
    outputHandlers: () => OutputHandlersList,
): OutputHandlerInterceptor {
    function interceptor(event: Event) {
        let message = interceptor.handler(event)

        let currentOutputHandlerNode: OutputHandlersList = outputHandlers()

        while ('next' in currentOutputHandlerNode) {
            if ('value' in currentOutputHandlerNode) {
                const { value } = currentOutputHandlerNode

                if (typeof value === 'function') {
                    message = value(message)
                } else {
                    for (let i = value.length; i--; ) {
                        message = value[i](message)
                    }
                }
            }

            currentOutputHandlerNode = currentOutputHandlerNode.next
        }

        currentOutputHandlerNode(message)
    }

    interceptor.handler = handler

    return interceptor
}
