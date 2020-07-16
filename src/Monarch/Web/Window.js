"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports._cancelIdleCallback = exports._requestIdleCallback = exports._cancelAnimationFrame = exports._requestAnimationFrame = exports.clearInterval = exports.setInterval = exports.clearTimeout = exports.setTimeout = void 0;
exports.setTimeout = function (n) { return function (f) { return function () { return window.setTimeout(f, n); }; }; };
exports.clearTimeout = function (id) { return function () { return window.clearTimeout(id); }; };
exports.setInterval = function (n) { return function (f) { return function () { return window.setInterval(f, n); }; }; };
exports.clearInterval = function (id) { return function () { return window.clearInterval(id); }; };
exports._requestAnimationFrame = function (f) {
    return function () { return window.requestAnimationFrame(f); };
};
exports._cancelAnimationFrame = function (id) {
    return function () { return window.cancelAnimationFrame(id); };
};
exports._requestIdleCallback = function (timeout) { return function (f) {
    return function () { return window.requestIdleCallback(f, { timeout: timeout }); };
}; };
exports._cancelIdleCallback = function (id) {
    return function () { return window.cancelIdleCallback(id); };
};
