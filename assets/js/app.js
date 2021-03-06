// Generated by CoffeeScript 1.7.1

/* Application skeleton */

(function() {
  var __slice = [].slice;

  this.Application = {
    Class: {
      Model: {},
      Collection: {},
      View: {}
    },
    Model: {},
    Collection: {},
    View: {},
    Templates: {},
    _startFunctions: [],

    /* start module */
    onStart: function(func) {
      var isFunction;
      isFunction = _.isFunction(func);
      if (isFunction) {
        Application._startFunctions.push(func);
      }
      return isFunction;
    },

    /* load templates */
    loadTemplates: function() {
      var template, templates, _i, _len;
      templates = $("script[type='text/template']");
      for (_i = 0, _len = templates.length; _i < _len; _i++) {
        template = templates[_i];
        Application.Templates[$(template).attr('id')] = Handlebars.compile($(template).html());
      }
      return templates.length;
    },

    /* Start app */
    Start: function() {
      if (TEST_MODE) {
        $('body').append(Application.Templates.tplTest());
        if (_.isObject(Application.startTest)) {
          Application._startTest = _.extend(Application._startTest, Application.startTest);
        }
        if (_.isObject(Application.runTest)) {
          Application._runTest = _.extend(Application._runTest, Application.runTest);
        }
        _(Application._startTest).each(function(func, name) {
          return test(name, func);
        });
        Application.Test('runTest1', this, 22);
      }
      return _(Application._startFunctions).each(function(func) {
        return func();
      });
    },
    genId: function(prefix) {
      if (prefix == null) {
        prefix = 'Object';
      }
      return "" + prefix + "-" + (rand(0xFFFFFF)) + "-" + (rand(0xFFFFFF)) + "-" + (rand(0xFFFFFF)) + "-" + (rand(0xFFFFFF));
    },
    Test: function() {
      var attr, name, runTest, thisPointer;
      name = arguments[0], thisPointer = arguments[1], attr = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (TEST_MODE && (runTest = Application._runTest[name])) {
        if (thisPointer == null) {
          thisPointer = this;
        }
        return test(name, _.bind.apply(_, [runTest, thisPointer].concat(__slice.call(attr))));
      }
    }
  };

  Application._startTest = {};

  Application._runTest = {};


  /* Ginger options */

  _(Backbone.Ginger.options).extend({
    templateParentObject: Application.Templates,
    modelImportParentObject: Application.Class.Model,
    collectionImportParentObject: Application.Class.Collection,
    collectionImportVariable: '#'
  });


  /* Autolink model handler */

  Backbone.Model.prototype.initialize = function() {
    var attr, event, handle, _ref;
    attr = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (_.isObject(this.handler)) {
      _ref = this.handler;
      for (event in _ref) {
        handle = _ref[event];
        if (_.isFunction(handle)) {
          this.on(event, handle);
        }
      }
    }
    if (_.isFunction(this.init)) {
      return this.init.apply(this, attr);
    }
  };


  /* Main init */

  $(function() {
    var appStart, includes;
    appStart = function() {
      Application.loadTemplates();
      return Application.Start();
    };
    if (document.URL.indexOf('?reset') >= 0) {
      window.localStorage.clear();
    }
    includes = 0;
    $('include').each(function() {
      var node;
      node = $(this);
      if (node.attr('src')) {
        includes++;
        return $.get(node.attr('src'), function(res) {
          node[0].outerHTML = res;
          if (--includes <= 0) {
            return appStart();
          }
        });
      }
    });
    if (!includes) {
      return appStart();
    }
  });

}).call(this);

//# sourceMappingURL=app.map
