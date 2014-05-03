$.fn.cursorToEnd = function(pos) {
    var rng, sel;
    this.each(function(index, elem) {
        if(document.createRange) {
            rng = document.createRange();
            rng.selectNodeContents(elem);
            rng.collapse(false);
            sel = window.getSelection();
            sel.removeAllRanges();
            sel.addRange(rng);
        } else {
            var rng = document.body.createTextRange();
            rng.moveToElementText(elem);
            rng.collapseToEnd();
            rng.select();
        }
    });
    return this;
}

function rand(min, max) {
    if(max == undefined) {
        max = min;
        min = 0;
    }
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function htmlSpecialChars(val) {
    var html = val.toString();
    html = html.replace(/&/g, "&amp;");
    html = html.replace(/</g, "&lt;");
    html = html.replace(/>/g, "&gt;");
    html = html.replace(/"/g, "&quot;");
    return html;
}

function setCookie(name, value, expires, path, domain, secure) {
    document.cookie = name + "=" + escape(value) +
        ((expires) ? "; expires=" + expires : "") +
        ((path) ? "; path=" + path : "") +
        ((domain) ? "; domain=" + domain : "") +
        ((secure) ? "; secure" : "");
}

function getCookie(name) {
    var cookie = " " + document.cookie;
    var search = " " + name + "=";
    var setStr = null;
    var offset = 0;
    var end = 0;
    if(cookie.length > 0) {
        offset = cookie.indexOf(search);
        if(offset != -1) {
            offset += search.length;
            end = cookie.indexOf(";", offset)
            if(end == -1) {
                end = cookie.length;
            }
            setStr = unescape(cookie.substring(offset, end));
        }
    }
    return(setStr);
}

function _odump() {

    if(!arguments.length)return;

    this.maxlevel = 2;
    var n = (arguments.length == 1 ? 0 : parseInt(arguments[arguments.length - 1]));

    this.hide = n < 100;

    this.dump_val = function(val, key, lev) {

        if(key == 'ownerDocument')return "<tr><td>[[object ownerDocument]]</td><td>ownerDocument</td><td></td></tr>";

        var level = (lev == undefined ? 0 : lev);

        var out = '<tr valign=top style="background-color:#' + ((arguments.callee.bbg = !arguments.callee.bbg) ? 'BBC' : 'EEF') + ';"><td align=right>';

        if(val == null) {
            out += 'Null</td>' + (key == undefined ? '' : '<td align=right>' + key + '</td>') + '<td>Null</td>';
        } else if(typeof(val) == 'object') {
            var type = '[[OBJECT]]';

            if(typeof(val.toString) == 'function') {
                var v = val.toString();
                if(v.split('object')[0] == '[')type = v; else type = 'Array (' + val.length + ')';
            } else {
                type = '[[object with no no toString()]]';
            }

            out += type + "</td>" + (key == undefined ? '' : '<td align=right>' + key + '</td>') + '<td align=left>';

            if(level < this.maxlevel) {
                out += "<table cellpadding=\"3px\"><thead onclick='$(this).parent().find(\"tbody:eq(0)\").slideToggle(\"fast\");'><tr><th>type</th><th>key</th><th>value</th></tr></thead><tbody " + (level > 0 && this.hide ? "class='tohide'" : '') + ">";

                var tmp = this.dump_val.bbg;
                this.dump_val.bbg = true;
                for(k in val) {
                    out += this.dump_val(val[k], k, level + 1);
                }
                this.dump_val.bbg = tmp;

                out += "</table>";
            } else {
                out += '<div style="color:#447;font-weight:bold;">---></div>';
            }

        } else {
            out += (typeof(val) == 'string' ? 'string (' + val.length + ')' : typeof(val)) + '</td>' + (key == undefined ? '' : '<td align=right>' + key + '</td>') + '<td align=left><b>' + (typeof(val) == 'function' ? "<div><div style='cursor:pointer;' onclick='$(this).parent().find(\".wtext:eq(0)\").slideToggle(\"fast\");'>[FUNCTION&nbsp;TEXT]</div><div class='wtext' style='display:none' contenteditable='true'>" + htmlSpecialChars(val) + "</div></div>" : htmlSpecialChars(val));
        }

        return out += '</td></tr>';
    }

    if(document.getElementById('watcher') == null) {
        var x = (getCookie('watcher_x') == null ? 0 : getCookie('watcher_x'));
        var y = (getCookie('watcher_y') == null ? 0 : getCookie('watcher_y'));

        $('head').append("<style>" +
            "#watcher{border:2px solid #779;font-family:Verdana;font-size:14px;position:absolute;color:black;background-color:white;opacity:0.9;z-index:9999;left:" + (x < 0 ? 0 : x) + "px;top:" + (y < 0 ? 0 : y) + "px;}" +
            "#wcaption{padding:5px;background-color:#AAF;cursor:move}" +
            "#watcher table{border: 1px solid #555;border-collapse:collapse;margin-top:3px;}" +
            "#watcher thead{font-weight:bold;text-align:center;background-color:#AAF;cursor:pointer;}" +
            "#watcher textarea{width:400px;height:300px;}" +
            ".tohide {display:none;}" +
            "#watcher td{border: 1px solid #555;}" +
            "</style>");

        $('body').append("<div id='watcher'><div id='wcaption'>Watcher v0.1</div><!--div style='width:100%'><form onsubmit='return false;'><input id='wtext' /><input type='submit' value='>' /></form></div--><div id='wbody'></div></div>");

        $('#wcaption').mousedown(function(e) {
            $('#watcher').attr('bx', e.screenX);
            $('#watcher').attr('by', e.screenY);
            $('#watcher').attr('ox', $('#watcher').position().left);
            $('#watcher').attr('oy', $('#watcher').position().top);

            $(document).mousemove(function(e) {
                $('#watcher').css({
                    left: parseInt($('#watcher').attr('ox')) + e.screenX - parseInt($('#watcher').attr('bx')),
                    top: parseInt($('#watcher').attr('oy')) + e.screenY - parseInt($('#watcher').attr('by'))
                });
                return false;

            });

            return false;
        });

        $(document).mouseup(function(e) {
            setCookie('watcher_x', $('#watcher').position().left);
            setCookie('watcher_y', $('#watcher').position().top);
            $(document).unbind('mousemove');
        });

    }

    this.dump_val.lvl = 0;
    this.dump_val.level = 0;

    if(document.getElementById('watcher_' + n) == null) {
        $('#wbody').append("<div id='watcher_" + n + "' style='padding:5px; border:5px solid  #333;'>ERROR</div>");
    }

    var out = "<table cellpadding='3px'><thead onclick='$(this).parent().find(\"tbody:eq(0)\").slideToggle(\"fast\");'><tr><td>type</td><td>value</td></tr></thead><tbody>";

    this.dump_val.bbg = false;

    for(var i = 0; j = (arguments.length == 1 ? 1 : arguments.length - 1), i < j; i++) {
        out += this.dump_val(arguments[i]);
    }

    $('#watcher_' + n).html("Watcher #" + n + out + '</tbody></table>');
}

/**
 * Watcher that placed on new position
 * @private
 */
function __dump() {
    _dump.prototype.wrapper.call(_dump.prototype.wrapper.prototype, true, arguments);
}

/**
 * Watcher placed at same position
 * @private
 */
function _dump() {
    _dump.prototype.wrapper.call(_dump.prototype.wrapper.prototype, false, arguments);
}

_dump.prototype.header = function(title) {
    return $('<div><div class="jsWatcher-Slide jsWatcher-SlideClosed jsWatcher-NextLevelHeader">' + (title ? title + ' ' : '') + '<div class="jsWatcher-arrow jsWatcher-triangle-right"></div></div>' +
        '<div class="jsWatcher-TableWrap"><table class="jsWatcher-DumpNodeTable">' +
        '<thead><tr><td>Type</td><td>Key</td><td>Val</td></tr></thead><tbody></tbody></table></div></div>');
}

_dump.prototype.dump = function(id, $node, vars, expand) {
    var val = null;
    var typeClass = '';
    var typeName = '';
    var keyName = '';
    var len = 0;
    if(!this.cache) {
        this.cache = {};
    }

    if(!this.cache[id]) {
        this.cache[id] = {};
    }

    var mainCache = this.cache[id];
    var cache = null;
    var valDisplay = '';

    for(var key in vars) {
        if(!this.cache[id][key]) {
            this.cache[id][key] = {
                firstTime: true,
                expand: !!expand
            };
        }

        cache = this.cache[id][key];

        val = vars[key];
        valDisplay = '';

        if(cache.val != val || cache.firstTime || typeof(val) == 'object') {
            cache.val = val;
        } else {
            continue;
        }

        if(!cache.$tr) {
            var td = '<td></td>';
            cache.$tr = $('<tr class="jsWatcher-dumpTR"></tr>');
            cache.$tdType = $(td);
            cache.$tdKey = $(td);
            cache.$tdVal = $(td);

            cache.$tr.append(cache.$tdType);
            cache.$tr.append(cache.$tdKey);
            cache.$tr.append(cache.$tdVal);

            if(typeof(val) == 'object' && !!val) {
                cache.$nextLevel = _dump.prototype.header();
                cache.$nextLevelNode = cache.$nextLevel.find('tbody');
                cache.$nextLevelHeader = cache.$nextLevel.find('.jsWatcher-NextLevelHeader');

                cache.$nextLevelHeader.click(
                    (function(iid, parentCache, vars) {
                        return function() {
                            parentCache.expand = !parentCache.expand;
                            $(this)
                                .toggleClass('jsWatcher-SlideClosed')
                                .find('.jsWatcher-arrow')
                                .toggleClass('jsWatcher-triangle-right')
                                .toggleClass('jsWatcher-triangle-down');

                            $(this)
                                .next()
                                .slideToggle('fast');
                            if(parentCache.expand) {
                                _dump.prototype.dump.call(_dump.prototype.dump.prototype, iid, parentCache.$nextLevelNode, vars);
                            }
                        }
                    })(id + ' level ' + key, cache, val));

                if(cache.expand) {
                    cache.expand = false;
                    cache.$nextLevelHeader.trigger('click');
                }
            }
            $node.append(cache.$tr);
        }

        if(typeof(val) == 'object') {
            typeName = '[Object]';
            typeClass = 'typeObject';
            if(val == null) {
                typeName = 'null';
                typeClass = 'typeNull';
            } else {
                if(typeof(val.toString) == 'function') {
                    var v = val.toString();
                    if(v.split('object')[0] == '[' || val.length == undefined) {
                        typeName = v.split(',')[0].split(' ');

                        if(typeName.length > 1) {
                            typeName = typeName[1];
                            typeName = typeName.substr(0, typeName.length - 1) + ' ';
                        } else {
                            typeName = typeName[0];
                        }
                        len = Object.keys(val).length + (!!val.__proto__ ? Object.keys(val.__proto__).length : 0);

                        if(len) {
                            typeName += '(<span class="jsWatcher-typeNum">' + len + '</span>)';

                        } else {
                            typeName += '<sup class="jsWatcher-Sup">empty</sup>';
                        }
                    } else {
                        typeClass = 'typeArray';
                        typeName = 'Array (<span class="jsWatcher-typeNum">' + val.length + '</span>)';
                    }
                } else {
                    typeName = 'object with no toString()';
                }

                if(cache.expand) {
                    _dump.prototype.dump.call(_dump.prototype.dump.prototype, id + ' level ' + key, cache.$nextLevelNode, val);
                }

                if(!cache.$tdVal.html()) {
                    cache.$tdVal.append(cache.$nextLevel);
                }

            }
        } else {
            switch(typeof(val)) {
                case 'string':
                    typeName = 'string (<span class="jsWatcher-typeNum">' + val.length + '</span>)';
                    typeClass = 'typeString';
                    valDisplay = '<pre>' + $('<div></div>').text(val).html() + '</pre>';
                    break;
                case 'function':
                    typeName = 'Function';
                    typeClass = 'typeFunction';
                    var func = val.toString();
                    valDisplay = '<pre>' + $('<div></div>').text(func).html() + '</pre>';
                    if((func.length <= 17 || func.substr(-17) != '{ [native code] }') && func.length > 10) {
                        valDisplay = '<div class="jsWatcher-Slide" onclick="$(this).find(\'.jsWatcher-arrow\').toggleClass(\'jsWatcher-triangle-right\').toggleClass(\'jsWatcher-triangle-down\');$(this).next().slideToggle(\'fast\')">function <div class="jsWatcher-arrow jsWatcher-triangle-right"></div></div><div style="display:none;">' + valDisplay + '</div>'
                    }
                    break;
                case 'number' :
                    if(isNaN(val)) {
                        typeName = 'NaN';
                        typeClass = 'typeNull';
                    } else {
                        if(parseInt(val) == parseFloat(val)) {
                            typeName = 'int';
                            typeClass = 'typeNum';
                            valDisplay = val;
                        } else {
                            typeName = 'float';
                            typeClass = 'typeNum';
                            valDisplay = val;
                        }
                    }
                    break;
                case 'boolean' :
                    typeName = 'bool';
                    typeClass = 'typeBoolean';
                    valDisplay = val ? 'true' : 'false';
                    break;

                case 'undefined' :
                    typeName = 'undefined';
                    typeClass = 'typeNull';
                    break;
                default :
                    typeName = typeof(val);
                    JSON.stringify(val);
            }
            cache.$tdVal.html(valDisplay).attr('class', 'jsWatcher-' + typeClass);
            if(cache.expand) {
                cache.$tdVal.find('.jsWatcher-Slide').trigger('click');
            }
        }

        keyName = key;
        if(!vars.hasOwnProperty(key) && vars.__proto__.hasOwnProperty(key)) {
            keyName += ' <sup class="jsWatcher-Sup">proto</sup>';
        }

        cache.$tdType.html(typeName).attr('class', 'jsWatcher-' + typeClass);

        cache.$tdKey.html(keyName).attr('class', 'jsWatcher-' + (typeof(key) == 'number' ? 'typeNum' : 'typeString'));

        if(cache.firstTime) {
            cache.firstTime = false;
        }
    }

    //cleanUP
    for(var key in mainCache) {
        if(!vars.hasOwnProperty(key) && !vars.__proto__.hasOwnProperty(key)) {
            mainCache[key].$tr.remove();
            delete mainCache[key];
        }
    }
}

_dump.prototype.cache = {};

_dump.prototype.wrapper = function(newWatcher, vars) {
    var time = new Date().getTime();
    if(!this.watcher) {
        this.watcher = {
            $node: $('<div class="jsWatcher-MainNode"><div class="jsWatcher-MainNodeHeader">&nbsp;Watcher 2.0a</div><div class="jsWatcher-MainNodeBody"></div></div>')
        };
        this.watcher.$header = this.watcher.$node.find('.jsWatcher-MainNodeHeader');
        this.watcher.$body = this.watcher.$node.find('.jsWatcher-MainNodeBody');

        $('body').append(
            "<style>" +
                ".jsWatcher-MainNode {z-index:999999999;border-radius:3px; background-color:#aaa; border:1px solid #3A209E;position:absolute;font-family:arial;font-size:14px;}" +
                ".jsWatcher-MainNodeHeader {background-color:#3A209E; color:white;}" +
                ".jsWatcher-TableWrap {display:none;border:1px solid #3A209E;border-radius: 0 0 3px 3px;}" +
                ".jsWatcher-DumpNode {border-collapse:collapsed;border-radius:3px;}" +
                ".jsWatcher-DumpNode tr:nth-child(odd){background-color:#FFF;}" +
                ".jsWatcher-DumpNode tr:nth-child(even){background-color:#F0F0F0;}" +

                ".jsWatcher-DumpNode td, .jsWatcher-DumpNode pre{padding:3px;font-size:14px;line-height:14px;margin:0px;}" +
                ".jsWatcher-DumpNode td {vertical-align:top;font-family:arial;font-size:14px;color:#333;line-height:14px;border:1px solid #999;}" +
                ".jsWatcher-DumpNode pre{background-color:#ddf;font-family:monospace;font-size:14px;display:inline-block;}" +

                ".jsWatcher-Slide { cursor:pointer;background-color:#3A209E;color:white;padding:4px;border-radius:3px 3px 0 0;}" +
                ".jsWatcher-SlideClosed {border-radius:3px !important;}" +
                ".jsWatcher-triangle-right {border-top: 5px solid transparent;border-left: 10px solid yellow;border-bottom: 5px solid transparent;display:inline-block;width: 0px;height: 0px;}" +
                ".jsWatcher-triangle-down  {width: 0;height: 0;border-left: 5px solid transparent;border-right: 5px solid transparent;border-top: 10px solid yellow;display:inline-block;}" +

                ".jsWatcher-typeString {color: #007 !important;}" +
                ".jsWatcher-typeNum {color: #700 !important;font-family:monospace !important;}" +
                ".jsWatcher-typeNull {color: #707 !important;}" +
                ".jsWatcher-typeBoolean {color: #070 !important;}" +
                ".jsWatcher-Sup {background-color: #FF7;}" +

                "</style>")
        $('body').append(this.watcher.$node);

        var x = (getCookie('watcher_x') == null ? 0 : getCookie('watcher_x'));
        var y = (getCookie('watcher_y') == null ? 0 : getCookie('watcher_y'));

        this.watcher.$node.css({
            top: parseInt(y),
            left: parseInt(x)
        });

        this.watcher.c = {};
        this.watcher.$header.mousedown((function(watcher) {
            return function(e) {
                watcher.c.bx = e.screenX;
                watcher.c.by = e.screenY;
                watcher.c.ox = parseInt(watcher.$node.position().left);
                watcher.c.oy = parseInt(watcher.$node.position().top);

                $(document).mousemove(function(e) {
                    watcher.$node.css({
                        left: watcher.c.ox + e.screenX - watcher.c.bx,
                        top: watcher.c.oy + e.screenY - watcher.c.by
                    });
                    return false;

                });
                return false;
            }
        })(this.watcher));

        $(document).mouseup((function($watcherNode) {
            return function() {
                setCookie('watcher_x', $watcherNode.position().left);
                setCookie('watcher_y', $watcherNode.position().top);
                $(document).unbind('mousemove');
            }
        })(this.watcher.$node));

    }
    var watcher = this.watcher;

    try {
        watcher.prop.notExist += 1;
    } catch(e) {

        var caller = e.stack.split("\n")[3].split(' ').slice(-3);
        if(caller.length < 3) {
            caller = e.stack.split("\n")[2].split('@').slice(-3);
            caller[2] = caller[1];
            caller[1] = caller[0];
        }

        var name = !!caller[0] ? 'function ' + caller[1] : '(anonymous function)';
        var source = caller[2][0] == '(' ? caller[2].substr(1, caller[2].length - 2) : caller[2];
        source = source.split('/').slice(3).join('/').split(':');

        if(source[1] == undefined) {
            source = 'console';
        } else {
            source = '/' + source[0] + ' at ' + source[1] + (source[2] ? ':' + source[2] : '');
        }
        var cacheVariable = 'jsWatcher-' + 'Cache';

        var calleeCache = _dump.prototype.cache;

        if(!!newWatcher) {
            var cnt = 0;
            while(!!calleeCache[(source + ' #' + (cnt = rand(0xFFFFFF)))]) {
            }
            source = (source + ' #' + cnt);
        }

        var cache = null;

        if(!(cache = calleeCache[source])) {
            calleeCache.length += 1;
            cache = calleeCache[source] = {
                $node: $('<div class="jsWatcher-DumpNode"><table class="jsWatcher-DumpNodeTable">' +
                    '<thead><tr><td colspan=3>' + name + '() <pre>' + source + '</pre> <span class="jsWatcher-typeNum jsWatcher-timer"> </span></td></tr></thead><tbody></tbody></table></div>')
            };
            cache.$table = cache.$node.find('tbody');
            cache.$timer = cache.$node.find('.jsWatcher-timer');
            this.watcher.$body.append(cache.$node);
        }

        if(cache.lastTime) {
            cache.$timer.text(((time - cache.lastTime) / 1000).toFixed(3));
        }
        _dump.prototype.dump.call(_dump.prototype.dump.prototype, source, cache.$table, vars, true);
        cache.lastTime = new Date().getTime();
    }
}




/* Dump matrix */

_mat = function(mat, id, subst) {
    var $mat, i, j, out, _i, _j, _len, _len1, _results;
    if (!$('#debugMat').length) {
        $('body').append($('<div id="debugMat" style="position: absolute;top:10px;left:10px;"></div>'));
    }
    if (!$("#debugMat_" + id).length) {
        $('#debugMat').append($("<div id=\"debugMat_" + id + "\" style=\"display: inline-block;padding:4px;\"><table style='border-collapse: collapse;'></table></div>"));
    }
    $mat = $("#debugMat_" + id + " table").empty();
    out = '';
    _results = [];
    for (_i = 0, _len = mat.length; _i < _len; _i++) {
        j = mat[_i];
        out = '';
        for (_j = 0, _len1 = j.length; _j < _len1; _j++) {
            i = j[_j];
            out += "<td style='border: 1px solid gray;width:16px;padding:1px;" + (i ? (i>30?(i>40?(i>60?'background-color:#ffb0ff':'background-color:#ffb0b0'):'background-color:#b0b0ff'):'background-color:#a0aaa0') : void 0) + "'>" + (subst?subst:i) + "</td>";
        }
        _results.push($mat.append("<tr>" + out + "</tr>"));
    }
    return _results;
};