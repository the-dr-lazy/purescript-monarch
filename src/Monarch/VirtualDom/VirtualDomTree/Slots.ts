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
import * as Children from 'monarch/Monarch/VirtualDom/VirtualDomTree/Children'
import * as LazyMorphism from 'monarch/Monarch/Data/LazyMorphism'

type Slots<message> = {
    default:
        | VirtualDomTree<message>
        | ReadonlyArray<VirtualDomTree<message>>
        | LazyMorphism.Type<VirtualDomTree<message> | ReadonlyArray<VirtualDomTree<message>>, Children.Type<message>>
} & {
    [key: string]: VirtualDomTree.ElementNS<message> | VirtualDomTree.CustomHtmlElement<message>
}
