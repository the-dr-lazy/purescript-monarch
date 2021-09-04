/*
 * Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
 * Copyright  : (c) 2020-2021 Monarch
 * License    : MPL 2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, version 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import { VirtualDomTree, NS } from 'monarch/Monarch/VirtualDom/VirtualDomTree'

const ns: NS = 'http://www.w3.org/2000/svg'

export const svg: VirtualDomTree.Node = facts => children => VirtualDomTree.mkElementNS(ns, 'svg', facts, children)
