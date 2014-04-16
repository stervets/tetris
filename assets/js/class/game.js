// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Application.Model.Player = (function(_super) {
    __extends(Player, _super);

    function Player() {
      return Player.__super__.constructor.apply(this, arguments);
    }

    Player.prototype.defaults = {
      name: 'PLayer',
      rating: 0
    };

    return Player;

  })(Backbone.Model);


  /*
   *   GAME MODEL
   */

  Application.Model.Game = (function(_super) {
    __extends(Game, _super);

    function Game() {
      return Game.__super__.constructor.apply(this, arguments);
    }

    Game.prototype.defaults = {
      mode: null
    };

    Game.prototype.proc = {};

    Game.prototype.gameReset = function() {
      this.proc = {};
      Application.shapeStack.reset();
      Application.shapeStack.generateShapes(4);
      Application.Pool.reset();
      return Application.Controller.reset();
    };

    Game.prototype["switch"] = function(mode) {
      if (this.attributes.mode === mode) {
        return this.trigger('change:mode', this, mode);
      } else {
        return this.set('mode', mode);
      }
    };

    Game.prototype.mode = [
      function() {}, function() {
        this.gameReset();
        this.proc.controller = new Application.Model.Controller.User();
        Application.Controller.add(this.proc.controller);
        this.proc.pool = new Application.Model.Pool({
          controller: this.proc.controller.id
        });
        return Application.Pool.add(this.proc.pool);
      }, function() {
        this.gameReset();
        this.proc.controller1 = new Application.Model.Controller.User();
        Application.Controller.add(this.proc.controller1);
        this.proc.pool1 = new Application.Model.Pool({
          controller: this.proc.controller1.id
        });
        Application.Pool.add(this.proc.pool1);
        this.proc.controller2 = new Application.Model.Controller.AI({
          formula: 2
        });
        Application.Controller.add(this.proc.controller2);
        this.proc.pool2 = new Application.Model.Pool({
          controller: this.proc.controller2.id
        });
        return Application.Pool.add(this.proc.pool2);
      }, function() {
        var actionDelay;
        actionDelay = 150;
        this.gameReset();
        this.proc.controller1 = new Application.Model.Controller.AI({
          formula: CPU_FORMULA.CPU1,
          actionDelay: actionDelay
        });
        Application.Controller.add(this.proc.controller1);
        this.proc.pool1 = new Application.Model.Pool({
          controller: this.proc.controller1.id
        });
        Application.Pool.add(this.proc.pool1);
        this.proc.controller2 = new Application.Model.Controller.AI({
          formula: CPU_FORMULA.CPU2,
          actionDelay: actionDelay
        });
        Application.Controller.add(this.proc.controller2);
        this.proc.pool2 = new Application.Model.Pool({
          controller: this.proc.controller2.id
        });
        return Application.Pool.add(this.proc.pool2);
      }
    ];

    Game.prototype.handler = {
      'change:mode': function(model, mode) {
        if (this.mode[mode] != null) {
          return this.mode[mode].apply(this);
        }
      }
    };

    Game.prototype.init = function() {};

    return Game;

  })(Backbone.Model);


  /*
   *   GAME VIEW
   */

  Application.View.Game = (function(_super) {
    __extends(Game, _super);

    function Game() {
      return Game.__super__.constructor.apply(this, arguments);
    }

    Game.prototype.node = '#jsGame';

    Game.prototype.mode = [
      function() {}, function() {
        this.model.proc.view = new Application.View.Pool({
          x: 900 / 2 - 450 / 2,
          y: 50,
          model: this.model.proc.pool
        });
        this.$('#jsSinglePlay').html(this.model.proc.view.$el);
        this.model.proc.onGameOver = (function(_this) {
          return function() {
            Application.Sound.musicStop();
            _this.$('#jsSinglePlayGameOver .jsScore').text(_this.model.proc.pool.lines);
            return _this.$('#jsSinglePlayGameOver').css({
              opacity: 0,
              scale: 0
            }).show().transition({
              opacity: 1,
              scale: 1
            }, VIEW_ANIMATE_TIME);
          };
        })(this);
        this.listenTo(this.model.proc.pool, 'gameover', this.model.proc.onGameOver);
        return Application.Sound.musicPlay();
      }, function() {
        this.model.proc.view1 = new Application.View.Pool({
          x: 450 / 2 - 450 / 2,
          y: 50,
          model: this.model.proc.pool1
        });
        this.$('#jsPlayerVsCpu').html(this.model.proc.view1.$el);
        this.model.proc.view2 = new Application.View.Pool({
          x: 1350 / 2 - 450 / 2,
          y: 50,
          model: this.model.proc.pool2
        });
        this.$('#jsPlayerVsCpu').append(this.model.proc.view2.$el);
        this.model.proc.onGameOver = (function(_this) {
          return function() {
            _this.model.proc.pool1.trigger('action', 'stop');
            _this.model.proc.pool2.trigger('action', 'stop');
            Application.Sound.musicStop();
            _this.$('.jsGameOverWinLoose').hide();
            if (_this.model.proc.pool1.lines === _this.model.proc.pool2.lines) {
              _this.$('.jsGameOverDraw').show();
            } else {
              if (_this.model.proc.pool1.lines >= _this.model.proc.pool2.lines) {
                _this.$('.jsGameOverWin').show();
              } else {
                _this.$('.jsGameOverLoose').show();
              }
            }
            _this.$('#jsPlayerVsCpuGameOver .jsScore').text(_this.model.proc.pool1.lines);
            return _this.$('#jsPlayerVsCpuGameOver').css({
              opacity: 0,
              scale: 0
            }).show().transition({
              opacity: 1,
              scale: 1
            }, VIEW_ANIMATE_TIME);
          };
        })(this);
        this.listenTo(this.model.proc.pool1, 'gameover', this.model.proc.onGameOver);
        this.listenTo(this.model.proc.pool2, 'gameover', this.model.proc.onGameOver);
        return Application.Sound.musicPlay();
      }, function() {
        var chartRepeat;
        this.model.proc.view1 = new Application.View.Pool({
          x: 450 / 2 - 450 / 2,
          y: 50,
          model: this.model.proc.pool1
        });
        this.$('#jsCpuVsCpu').html(this.model.proc.view1.$el);
        this.model.proc.view2 = new Application.View.Pool({
          x: 1350 / 2 - 450 / 2,
          y: 50,
          model: this.model.proc.pool2
        });
        this.$('#jsCpuVsCpu').append(this.model.proc.view2.$el);
        this.model.proc.onGameOver = (function(_this) {
          return function() {
            _this.model.proc.pool1.trigger('action', 'stop');
            _this.model.proc.pool2.trigger('action', 'stop');
            Application.Sound.musicStop();
            _this.$('.jsGameOverWinLoose').hide();
            if (_this.model.proc.pool1.lines === _this.model.proc.pool2.lines) {
              _this.$('.jsGameOverDraw').show();
            } else {
              if (_this.model.proc.pool1.lines >= _this.model.proc.pool2.lines) {
                _this.$('.jsGameOverCpu1').show();
              } else {
                _this.$('.jsGameOverCpu2').show();
              }
            }
            _this.$('#jsCpuVsCpuGameOver .jsScoreCpu1').text(_this.model.proc.pool1.lines);
            _this.$('#jsCpuVsCpuGameOver .jsScoreCpu2').text(_this.model.proc.pool2.lines);
            return _this.$('#jsCpuVsCpuGameOver').css({
              opacity: 0,
              scale: 0
            }).show().transition({
              opacity: 1,
              scale: 1
            }, VIEW_ANIMATE_TIME);
          };
        })(this);
        this.listenTo(this.model.proc.pool1, 'gameover', this.model.proc.onGameOver);
        this.listenTo(this.model.proc.pool2, 'gameover', this.model.proc.onGameOver);
        Application.Sound.musicPlay();
        $('#jsChart').highcharts({
          colors: ['#303090', '#903030'],
          legend: {
            enabled: false
          },
          chart: {
            type: 'line'
          },
          title: null,
          series: [
            {
              data: [],
              marker: {
                enabled: false
              }
            }, {
              data: [],
              marker: {
                enabled: false
              }
            }
          ],
          yAxis: {
            title: null
          }
        });
        this.model.proc.charts = $('#jsChart').highcharts();
        chartRepeat = (function(_this) {
          return function() {
            _this.model.proc.charts.series[0].addPoint(_this.model.proc.pool1.lines);
            _this.model.proc.charts.series[1].addPoint(_this.model.proc.pool2.lines);
            return _.delay(chartRepeat, 1000);
          };
        })(this);
        return chartRepeat();

        /*
        @model.proc.onLines1 = ->
            @model.proc.charts.series[0].addPoint(@model.proc.pool1.lines);
        
        @model.proc.onLines2 = ->
            @model.proc.charts.series[1].addPoint(@model.proc.pool2.lines);
        
        @listenTo @model.proc.pool1, 'lines', @model.proc.onLines1
        @listenTo @model.proc.pool2, 'lines', @model.proc.onLines2
         */
      }
    ];

    Game.prototype.modelHandler = {
      change: function() {},
      'change:mode': function(model, mode) {
        var $gameInner, delay;
        if (this.mode[mode] != null) {
          delay = this.$('.game-inner:visible').length ? VIEW_ANIMATE_TIME : 0;
        }
        $gameInner = this.$('.game-inner');
        return $gameInner.transition({
          opacity: 0
        }, _.once((function(_this) {
          return function() {
            _this.$('.game-inner').hide();
            _this.mode[mode].apply(_this);
            return $($gameInner[mode]).css({
              opacity: 0
            }).show().transition({
              opacity: 1
            }, delay);
          };
        })(this), delay));
      }
    };

    Game.prototype.init = function() {
      this.$('#jsSinglePlayGameOver .jsPlayAgain').click(function() {
        return Application.Game["switch"](GAME_MODE.SINGLE_PLAYER);
      });
      this.$('#jsPlayerVsCpuGameOver .jsPlayAgain').click(function() {
        return Application.Game["switch"](GAME_MODE.PLAYER_VS_CPU);
      });
      this.$('#jsCpuVsCpuGameOver .jsPlayAgain').click(function() {
        return Application.Game["switch"](GAME_MODE.CPU_VS_CPU);
      });
      return this.$('.jsExitToMenu').click(function() {
        return Application.Game["switch"](GAME_MODE.LOBBY);
      });
    };

    return Game;

  })(Backbone.View);

}).call(this);

//# sourceMappingURL=game.map
