"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.h = exports.unmount = exports.patch = exports.mount = exports.virtualNodeMap = void 0;
var snabbdom_1 = require("snabbdom");
var class_1 = require("snabbdom/modules/class");
var props_1 = require("snabbdom/modules/props");
var style_1 = require("snabbdom/modules/style");
var eventlisteners_1 = require("snabbdom/modules/eventlisteners");
var h_1 = require("snabbdom/h");
function uncurryVirtualNodeMap(f, virtualNode) {
    var _a;
    if (typeof virtualNode === 'string')
        return virtualNode;
    if ((_a = virtualNode.data) === null || _a === void 0 ? void 0 : _a.on) {
        Object.entries(virtualNode.data.on).forEach(function (_a) {
            var key = _a[0], g = _a[1];
            function h(event) {
                return f(g(event));
            }
            virtualNode.data.on[key] = h;
        });
    }
    if (virtualNode.children) {
        virtualNode.children.forEach(function (child) { return exports.virtualNodeMap(f)(child); });
    }
    return virtualNode;
}
exports.virtualNodeMap = function (f) { return function (virtualNode) {
    return uncurryVirtualNodeMap(f, virtualNode);
}; };
function bindEventListeners(dispatch, virtualNode) {
    uncurryVirtualNodeMap(function (message) { return dispatch(message)(); }, virtualNode);
}
var _patch = snabbdom_1.init([
    class_1.classModule,
    props_1.propsModule,
    style_1.styleModule,
    eventlisteners_1.eventListenersModule,
]);
exports.mount = function (dispatch) { return function (element) { return function (virtualNode) {
    return function () { return (bindEventListeners(dispatch, virtualNode), _patch(element, virtualNode)); };
}; }; };
exports.patch = function (dispatch) { return function (previousVirtualNode) { return function (nextVirtualNode) {
    return function () { return (bindEventListeners(dispatch, nextVirtualNode), _patch(previousVirtualNode, nextVirtualNode)); };
}; }; };
exports.unmount = function (virtualNode) {
    return function () { return _patch(virtualNode, h_1.h('!')); };
};
exports.h = function (selector) { return function (spec) { return function (children) {
    return h_1.h(selector, spec, children);
}; }; };
