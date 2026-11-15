(function (global) {
    var CHANNEL = 'lb-tablet:mdt';
    var SCHEME_ATTRIBUTE = 'data-mdt-color-scheme';

    var pending = {};
    var listeners = {};
    var requestId = 0;
    var context = null;
    var readyResolvers = [];

    var colorScheme = 'light';
    var schemeApplied = false;
    var schemeQueries = [];
    var capturedRules = [];
    var schemeStyle = null;
    var nativeMatchMedia = global.matchMedia ? global.matchMedia.bind(global) : null;

    function schemeOf(condition) {
        var match = /prefers-color-scheme\s*:\s*(dark|light)/.exec(condition || '');

        return match ? match[1] : null;
    }

    function scopeSelector(selector, scheme) {
        var scope = 'html[' + SCHEME_ATTRIBUTE + '="' + scheme + '"]';

        return (selector || '')
            .split(',')
            .map(function (part) {
                var trimmed = part.trim();
                if (!trimmed) return '';

                if (/^(:root|html)/.test(trimmed)) return trimmed.replace(/^(:root|html)/, scope);

                return scope + ' ' + trimmed;
            })
            .filter(Boolean)
            .join(', ');
    }

    function remainingCondition(condition) {
        return condition
            .replace(/\(\s*prefers-color-scheme\s*:\s*(dark|light)\s*\)/g, '')
            .replace(/\band\s+and\b/g, 'and')
            .replace(/^\s*and\s+/, '')
            .replace(/\s+and\s*$/, '')
            .replace(/^\s*,\s*|\s*,\s*$/g, '')
            .trim();
    }

    function captureSchemeRules(rules) {
        for (var i = 0; i < rules.length; i++) {
            var rule = rules[i];
            if (!rule) continue;

            if (rule.type === 3) {
                try {
                    if (rule.styleSheet) captureSchemeRules(rule.styleSheet.cssRules);
                } catch (err) {}

                continue;
            }

            if (rule.type !== 4) continue;

            var condition = rule.conditionText || (rule.media && rule.media.mediaText) || '';
            var scheme = schemeOf(condition);
            if (!scheme) continue;

            capturedRules.push({ rule: rule, scheme: scheme, rest: remainingCondition(condition) });

            try {
                rule.media.mediaText = 'not all';
            } catch (err) {}
        }
    }

    function renderCapturedRules() {
        var output = [];

        capturedRules.forEach(function (entry) {
            var body = '';

            for (var i = 0; i < entry.rule.cssRules.length; i++) {
                var inner = entry.rule.cssRules[i];

                if (inner.type === 1) body += scopeSelector(inner.selectorText, entry.scheme) + '{' + inner.style.cssText + '}';
                else body += inner.cssText;
            }

            if (body) output.push(entry.rest ? '@media ' + entry.rest + '{' + body + '}' : body);
        });

        return output.join('');
    }

    function buildSchemeStyles() {
        if (!schemeApplied) return;

        for (var i = 0; i < document.styleSheets.length; i++) {
            var sheet = document.styleSheets[i];
            if (sheet.ownerNode === schemeStyle) continue;

            var rules = null;

            try {
                rules = sheet.cssRules;
            } catch (err) {
                continue;
            }

            if (rules) captureSchemeRules(rules);
        }

        if (!capturedRules.length) return;

        if (!schemeStyle) {
            schemeStyle = document.createElement('style');
            schemeStyle.setAttribute('data-mdt-color-scheme-shim', '');

            (document.head || document.documentElement).appendChild(schemeStyle);
        }

        schemeStyle.textContent = renderCapturedRules();
    }

    function notifySchemeQueries() {
        schemeQueries.slice().forEach(function (query) {
            query.update();
        });
    }

    function applyColorScheme(scheme) {
        colorScheme = scheme === 'dark' ? 'dark' : 'light';
        schemeApplied = true;

        var root = document.documentElement;

        if (root) {
            root.setAttribute(SCHEME_ATTRIBUTE, colorScheme);
            root.style.colorScheme = colorScheme;
        }

        buildSchemeStyles();
        notifySchemeQueries();
    }

    function createSchemeQuery(query, wants) {
        var callbacks = [];

        var list = {
            media: query,
            matches: colorScheme === wants,
            onchange: null,
            addEventListener: function (type, callback) {
                if (type === 'change' && callback) callbacks.push(callback);
            },
            removeEventListener: function (type, callback) {
                if (type !== 'change') return;

                callbacks = callbacks.filter(function (entry) {
                    return entry !== callback;
                });
            },
            addListener: function (callback) {
                list.addEventListener('change', callback);
            },
            removeListener: function (callback) {
                list.removeEventListener('change', callback);
            },
            dispatchEvent: function () {
                return true;
            },
            update: function () {
                var matches = colorScheme === wants;
                if (matches === list.matches) return;

                list.matches = matches;

                var event = { type: 'change', matches: matches, media: query, target: list, currentTarget: list };

                if (typeof list.onchange === 'function') list.onchange(event);

                callbacks.slice().forEach(function (callback) {
                    if (typeof callback === 'function') callback(event);
                    else if (callback && typeof callback.handleEvent === 'function') callback.handleEvent(event);
                });
            }
        };

        schemeQueries.push(list);

        return list;
    }

    if (nativeMatchMedia) {
        global.matchMedia = function (query) {
            var text = String(query);
            var wants = schemeOf(text);

            if (!wants) return nativeMatchMedia(query);

            return createSchemeQuery(text, wants);
        };
    }

    global.addEventListener('load', function () {
        buildSchemeStyles();
    });

    function emit(event, data) {
        var callbacks = listeners[event];
        if (!callbacks) return;

        callbacks.slice().forEach(function (callback) {
            try {
                callback(data);
            } catch (err) {
                console.error('[MDT] listener error', err);
            }
        });
    }

    function onMessage(event) {
        var message = event.data;
        if (!message || message.channel !== CHANNEL) return;

        if (message.event) {
            if (message.event === 'init') {
                context = message.data;

                applyColorScheme(context && context.theme);

                readyResolvers.splice(0).forEach(function (resolve) {
                    resolve(context);
                });
            }

            if (message.event === 'theme') applyColorScheme(message.data && message.data.theme);

            return emit(message.event, message.data);
        }

        if (message.id === undefined) return;

        var handlers = pending[message.id];
        if (!handlers) return;

        delete pending[message.id];

        if (message.ok) handlers.resolve(message.data);
        else handlers.reject(new Error(message.error || 'Unknown error'));
    }

    function send(action, payload) {
        return new Promise(function (resolve, reject) {
            if (!global.parent || global.parent === global) return reject(new Error('Not embedded in an MDT tab'));

            var id = ++requestId;
            pending[id] = { resolve: resolve, reject: reject };

            global.parent.postMessage({ channel: CHANNEL, id: id, action: action, payload: payload }, '*');
        });
    }

    global.addEventListener('message', onMessage);

    var MDT = {
        get context() {
            return context;
        },
        ready: function () {
            if (context) return Promise.resolve(context);

            return new Promise(function (resolve) {
                readyResolvers.push(resolve);

                send('getContext')
                    .then(function (data) {
                        context = data;

                        applyColorScheme(data && data.theme);

                        readyResolvers.splice(0).forEach(function (pendingResolve) {
                            pendingResolve(data);
                        });
                    })
                    .catch(function () {});
            });
        },
        get colorScheme() {
            return colorScheme;
        },
        refreshColorScheme: function () {
            buildSchemeStyles();

            return colorScheme;
        },
        getContext: function () {
            return send('getContext').then(function (data) {
                context = data;

                applyColorScheme(data && data.theme);

                return data;
            });
        },
        search: function (type, options) {
            var payload = typeof type === 'object' ? type : Object.assign({ type: type }, options || {});

            return send('search', payload);
        },
        navigate: function (view, tabId) {
            return send('navigate', { view: view, tabId: tabId });
        },
        openProfile: function (id) {
            return send('openProfile', { id: id });
        },
        openVehicle: function (plate) {
            return send('openVehicle', { plate: plate });
        },
        getTags: function () {
            return send('getTags');
        },
        notify: function (data) {
            return send('notify', data);
        },
        toggleInput: function (enabled) {
            return send('toggleInput', { enabled: enabled !== false });
        },
        request: function (action, data) {
            return send('request', { action: action, data: data });
        },
        on: function (event, callback) {
            listeners[event] = listeners[event] || [];
            listeners[event].push(callback);

            return MDT;
        },
        off: function (event, callback) {
            if (!listeners[event]) return MDT;

            listeners[event] = listeners[event].filter(function (entry) {
                return entry !== callback;
            });

            return MDT;
        }
    };

    global.MDT = MDT;

    if (typeof module !== 'undefined' && module.exports) module.exports = MDT;
})(window);
