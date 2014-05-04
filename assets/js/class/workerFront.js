// Generated by CoffeeScript 1.7.1
(function() {
  Application.workerCallback = {
    dump: function(vars) {
      return _dump.apply(null, vars);
    },
    mat: function(vars) {
      return _mat(vars.matrix, vars.id);
    },
    checkMoveDown: function(vars) {
      var pool;
      if ((pool = Application.Pool.get(vars.id)) && vars.key === pool.shape.key) {
        if (vars.collided) {
          return pool.trigger('action', 'putShape');
        } else {
          return pool.trigger('action', 'doMoveDown');
        }
      }
    },
    checkMoveLeft: function(vars) {
      var pool;
      if (pool = Application.Pool.get(vars.id)) {
        if (!vars.collided) {
          return pool.trigger('action', 'doMoveLeft');
        }
      }
    },
    checkMoveRight: function(vars) {
      var pool;
      if (pool = Application.Pool.get(vars.id)) {
        if (!vars.collided) {
          return pool.trigger('action', 'doMoveRight');
        }
      }
    },
    checkRotateLeft: function(vars) {
      var pool;
      if (pool = Application.Pool.get(vars.id)) {
        if (!vars.collided) {
          pool.setShapeXY(vars.x, vars.y);
          return pool.trigger('action', 'doRotateLeft');
        }
      }
    },
    checkRotateRight: function(vars) {
      var pool;
      if (pool = Application.Pool.get(vars.id)) {
        if (!vars.collided) {
          pool.setShapeXY(vars.x, vars.y);
          return pool.trigger('action', 'doRotateRight');
        }
      }
    },
    checkDrop: function(vars) {
      var pool;
      if (pool = Application.Pool.get(vars.id)) {
        pool.shape.set('drop', vars.drop);
        if (vars.setDrop) {
          pool.shape.set('y', vars.drop);
          return pool.trigger('action', 'putShape');
        }
      }
    },
    putShape: function(vars) {
      var pool;
      if (pool = Application.Pool.get(vars.id)) {
        pool.attributes.cells = vars.result.matrix;
        return pool.trigger('action', vars.result.overflow ? 'overflow' : 'onPutShape');
      }
    },
    process: function(vars) {
      var pool;
      if (pool = Application.Pool.get(vars.id)) {
        pool.attributes.cells = vars.matrix;
        if (vars.lines.length) {
          pool.score += Math.floor(vars.lines.length * vars.lines.length) * (++pool.combo);
          pool.trigger('action', 'lines', [vars.lines, pool.score, pool.combo]);
        } else {
          pool.combo = 0;
        }
        pool.trigger('action', 'nextShape');
        return pool.locked = false;
      }
    },
    findPlace: function(vars) {
      var controller;
      if (controller = Application.Controller.get(vars.id)) {
        return controller.trigger('setPath', vars.result);
      }
    },
    getScore: function(vars) {}
  };

  Application.worker = new Worker('/js/class/workerBack.js');

  Application.worker.addEventListener('message', function(e) {
    if (Application.workerCallback[e.data.callback] != null) {
      return Application.workerCallback[e.data.callback](e.data.vars, e.data.callback);
    }
  }, false);

}).call(this);

//# sourceMappingURL=workerFront.map
