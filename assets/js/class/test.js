// Generated by CoffeeScript 1.7.1
(function() {
  var CustomCharts, Proto,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Proto = (function() {
    Proto.prototype.params = {};

    Proto.prototype.getData = function() {
      return JSON.stringify(this.params);
    };

    Proto.prototype.setData = function(name, value) {
      if (typeof name === 'object') {
        return $.extend(this.params, params);
      } else {
        return this.params[name] = value;
      }
    };

    Proto.mydata = function() {
      return console.log(111);
    };

    function Proto(params) {
      $.extend(this.params, params);
      console.log('test');
    }

    return Proto;

  })();

  CustomCharts = (function(_super) {
    __extends(CustomCharts, _super);

    function CustomCharts(params) {
      CustomCharts.__super__.constructor.call(this, params);
      console.log('test2');
    }

    return CustomCharts;

  })(Proto);

}).call(this);

//# sourceMappingURL=test.map
