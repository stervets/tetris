// Generated by CoffeeScript 1.7.1

/* Game pool */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Application.Model.Pool = (function(_super) {
    __extends(Pool, _super);

    function Pool() {
      return Pool.__super__.constructor.apply(this, arguments);
    }

    Pool.prototype.defaults = {
      index: 0,
      cells: [],
      w: POOL.WIDTH,
      h: POOL.HEIGHT
    };

    Pool.prototype.lines = 0;

    Pool.prototype.shape = null;

    Pool.prototype.next = null;

    Pool.prototype.locked = false;

    Pool.prototype.controller = null;

    Pool.prototype.nextShape = function() {
      var next, shape;
      if (this.next.attributes.shape != null) {
        this.shape.setShape(this.next.attributes.index, this.next.attributes.angle);
        next = Application.shapeStack.getShape(this.attributes.index + 1);
        this.next.setShape(next.index, next.angle);
      } else {
        shape = Application.shapeStack.getShape(this.attributes.index);
        this.shape.setShape(shape.index, shape.angle);
        next = Application.shapeStack.getShape(this.attributes.index + 1);
        this.next.setShape(next.index, next.angle);
      }
      this.shape.key = Application.genId('Shape');
      this.worker('checkDrop');
      this.attributes.index++;
      return this.locked = false;
    };

    Pool.prototype.resetCells = function() {
      var cells, i, line, _i, _ref;
      this.trigger('action', 'stop');
      cells = [];
      line = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = this.attributes.w; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(0);
        }
        return _results;
      }).call(this);
      for (i = _i = 0, _ref = this.attributes.h; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        cells.push(line.slice(0));
      }
      this.attributes.cells = cells;
      return this.trigger('action', 'nextShape');
    };

    Pool.prototype.setShapeXY = function(x, y) {
      return this.shape.set({
        x: x,
        y: y
      });
    };

    Pool.prototype.worker = function(trigger, angle) {
      var atr;
      atr = this.attributes;
      if (angle == null) {
        angle = this.shape.attributes.angle;
      }
      return Application.worker.postMessage({
        trigger: trigger,
        vars: {
          matrix: atr.cells,
          shape: this.shape.attributes.shape[angle],
          x: this.shape.attributes.x,
          y: this.shape.attributes.y,
          id: this.id,
          key: this.shape.key
        }
      });
    };

    Pool.prototype.actions = {
      doMoveDown: function() {
        if (this.locked) {
          console.log("do move down passed");
          return;
        }
        return this.shape.set('y', this.shape.attributes.y + 1);
      },
      doMoveLeft: function() {
        if (this.locked) {
          console.log("do move left passed");
          return;
        }
        this.shape.set('x', this.shape.attributes.x - 1);
        return this.worker('checkDrop');
      },
      doMoveRight: function() {
        if (this.locked) {
          console.log("do move right passed");
          return;
        }
        this.shape.set('x', this.shape.attributes.x + 1);
        return this.worker('checkDrop');
      },
      doRotateLeft: function() {
        var angle;
        if (this.locked) {
          console.log("do rotate left passed");
          return;
        }
        angle = this.shape.attributes.angle - 1;
        if (angle < 0) {
          angle = 3;
        }
        this.shape.set('angle', angle);
        return this.worker('checkDrop');
      },
      doRotateRight: function() {
        var angle;
        if (this.locked) {
          console.log("do rotate right passed");
          return;
        }
        angle = this.shape.attributes.angle + 1;
        if (angle > 3) {
          angle = 0;
        }
        this.shape.set('angle', angle);
        return this.worker('checkDrop');
      },
      doDrop: function() {
        if (this.locked) {
          return;
        }
        if (this.shape.attributes.drop >= 0) {
          this.shape.set('y', this.shape.attributes.drop);
          return this.trigger('action', 'putShape');
        }
      },
      moveDown: function() {
        if (this.locked) {
          return;
        }
        return this.worker('checkMoveDown');
      },
      moveLeft: function() {
        if (this.locked) {
          return;
        }
        return this.worker('checkMoveLeft');
      },
      moveRight: function() {
        if (this.locked) {
          return;
        }
        return this.worker('checkMoveRight');
      },
      rotateLeft: function() {
        var angle;
        if (this.locked) {
          return;
        }
        angle = this.shape.attributes.angle - 1;
        if (angle < 0) {
          angle = 3;
        }
        return this.worker('checkRotateLeft', angle);
      },
      rotateRight: function() {
        var angle;
        if (this.locked) {
          return;
        }
        angle = this.shape.attributes.angle + 1;
        if (angle > 3) {
          angle = 0;
        }
        return this.worker('checkRotateRight', angle);
      },
      drop: function() {
        if (this.locked) {
          return;
        }
        if (this.shape.attributes.drop < 0) {
          return this.worker('checkMoveDown');
        } else {
          return this.trigger('action', 'doDrop');
        }
      },
      putShape: function() {
        this.locked = true;
        return this.worker('putShape');
      },
      nextShape: function() {
        return this.nextShape();
      },
      overflow: function() {
        this.trigger('action', 'stop');
        return this.trigger('gameover');
      },
      onPutShape: function() {
        return this.worker('process');
      },
      getScore: function() {
        return this.worker('getScore');
      },
      reset: function() {
        return this.resetCells();
      }
    };

    Pool.prototype.handler = {
      action: function() {
        var name, vars;
        name = arguments[0], vars = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        if (this.actions[name] != null) {
          this.actions[name].apply(this, vars);
        }
        if (this.controller.poolHandler[name] != null) {
          return this.controller.poolHandler[name].apply(this.controller, vars);
        }
      },
      actionCallback: function(tick, name, result) {}
    };

    Pool.prototype.init = function(params) {
      var controller;
      controller = Application.Controller.get(params.controller);
      if (controller == null) {
        throw new Error('Controller must be set');
      }
      controller.pool = this;
      this.controller = controller;
      this.set('id', Application.genId('Pool'));
      this.shape = new Application.Model.Shape();
      return this.next = new Application.Model.Shape();
    };

    return Pool;

  })(Backbone.Model);


  /* Game pool collection */

  Application.Collection.Pool = (function(_super) {
    __extends(Pool, _super);

    function Pool() {
      return Pool.__super__.constructor.apply(this, arguments);
    }

    Pool.prototype.model = Application.Model.Pool;

    return Pool;

  })(Backbone.Collection);

}).call(this);

//# sourceMappingURL=pool.map
