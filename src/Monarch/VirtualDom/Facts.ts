/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2021 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { VirtualDomTree } from 'monarch/Monarch/VirtualDom/VirtualDomTree'
import { OutputHandlersList } from 'monarch/Monarch/VirtualDom/OutputHandlersList'

const attributesKeyName = 'attributes'
const outputKeyPrefix = 'on'

export interface Facts {
    [key: string]: unknown
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

export function unsafe_organizeFacts(element: VirtualDomTree.ElementNS<any>): void {
    const organizedFacts: OrganizedFacts = {}

    const { facts } = element

    for (const key in facts!) {
        if (key === attributesKeyName) {
            organizedFacts[FactCategory.Attribute] = facts[key]

            continue
        }

        if (key.startsWith(outputKeyPrefix)) {
            const outputName = key.substr(outputKeyPrefix.length).toLowerCase()

            organizedFacts[FactCategory.Output] = organizedFacts[FactCategory.Output] || {}
            organizedFacts[FactCategory.Output]![outputName] = <OutputHandler>facts[key]

            continue
        }

        organizedFacts[FactCategory.Property] = organizedFacts[FactCategory.Property] || {}
        organizedFacts[FactCategory.Property]![key] = facts[key]
    }

    element.organizedFacts = organizedFacts
    element.facts = undefined
}

export function unsafe_applyFacts(domNode: Node, diff: OrganizedFacts): void {
    for (const category in diff) {
        const subDiff = (<any>diff)[category]

        switch (+category) {
            case FactCategory.Property:
                return unsafe_applyProperties(domNode, subDiff)
            case FactCategory.Attribute:
                return unsafe_applyAttributes(<Element>domNode, subDiff)
            case FactCategory.Output:
                return unsafe_applyOutputs(domNode, subDiff)
        }
    }
}

function unsafe_applyAttributes(domNode: Element, attributes: OrganizedFacts[FactCategory.Attribute]): void {
    for (var key in attributes) {
        const value = attributes[key]

        value !== undefined ? domNode.setAttribute(key, value) : domNode.removeAttribute(key)
    }
}

function unsafe_applyProperties(domNode: { [key: string]: any }, properties: OrganizedFacts[FactCategory.Property]): void {
    for (const key in properties) {
        domNode[key] = properties[key]
    }
}

declare global {
    interface Node {
        monarch_outputHandlerInterceptors?: { [name: string]: OutputHandlerInterceptor | undefined }
    }
}

function unsafe_applyOutputs(domNode: Node, outputs: OrganizedFacts[FactCategory.Output]): void {
    const outputHandlerInterceptors = (domNode.monarch_outputHandlerInterceptors = domNode.monarch_outputHandlerInterceptors || {})

    for (const name in outputs) {
        var newHandler = outputs[name]
        var oldOutputHandlerInterceptor = outputHandlerInterceptors[name]

        if (!newHandler) {
            domNode.removeEventListener(name, oldOutputHandlerInterceptor!)
            outputHandlerInterceptors[name] = undefined

            continue
        }

        if (oldOutputHandlerInterceptor) {
            oldOutputHandlerInterceptor.handler = newHandler

            continue
        }

        oldOutputHandlerInterceptor = mkOutputHandlerInterceptor(newHandler, () => domNode.monarch_outputHandlers!)
        domNode.addEventListener(name, oldOutputHandlerInterceptor)

        outputHandlerInterceptors[name] = oldOutputHandlerInterceptor
    }
}

interface OutputHandlerInterceptor {
    (event: Event): void
    handler<a>(event: Event): a
}

function mkOutputHandlerInterceptor(handler: <a>(event: Event) => a, outputHandlers: () => OutputHandlersList): OutputHandlerInterceptor {
    function interceptor(event: Event) {
        let message = interceptor.handler(event)

        let currentOutputHandlerNode: OutputHandlersList = outputHandlers()

        while ('next' in currentOutputHandlerNode) {
            if ('value' in currentOutputHandlerNode) {
                const { value } = currentOutputHandlerNode

                if (typeof value === 'function') {
                    message = value(message)
                } else {
                    for (let i = value.length; i--;) {
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
