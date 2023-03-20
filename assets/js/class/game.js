// Generated by CoffeeScript 2.7.0
(function() {
  var spellCast;

  spellCast = function(lines, score, combo) {
    var pool, spellValue, value;
    pool = Application.Pool.at(Application.Pool.at(0).id === this.id ? 1 : 0);
    if (value = lines.length + combo - 2) {
      spellValue = this.getSpell(SPELL.GROUND) - value;
      this.setSpell(SPELL.GROUND, spellValue > 0 ? spellValue : 0);
      return pool.setSpell(SPELL.GROUND, pool.getSpell() + Math.abs(spellValue));
    }
  };

  Application.Model.Player = (function() {
    class Player extends Backbone.Model {};

    Player.prototype.defaults = {
      name: 'PLayer',
      rating: 0
    };

    return Player;

  }).call(this);

  Application.Model.Game = (function() {
    /*
     *   GAME MODEL
     */
    class Game extends Backbone.Model {
      gameReset() {
        this.proc = {};
        Application.shapeStack.reset();
        Application.shapeStack.generateShapes(4);
        Application.Pool.reset();
        return Application.Controller.reset();
      }

      switch(mode) {
        if (this.attributes.mode === mode) {
          return this.trigger('change:mode', this, mode);
        } else {
          return this.set('mode', mode);
        }
      }

      init() {}

    };

    Game.prototype.defaults = {
      mode: null
    };

    Game.prototype.proc = {};

    Game.prototype.mode = [
      function() {},
//loading
      function() {        //Lobby
        return this.gameReset();
      },
      function() {        // Single player
        this.gameReset();
        this.proc.controller = new Application.Model.Controller.User();
        //@proc.controller = new Application.Model.Controller.AI
        //    formula: CPU[0].FORMULA
        //    smart: CPU[0].SMART
        //    actionDelay: 150
        Application.Controller.add(this.proc.controller);
        this.proc.pool = new Application.Model.Pool({
          controller: this.proc.controller.id
        });
        Application.Pool.add(this.proc.pool);
        return this.proc.controller.start();
      },
      function() {        //PLayer vs CPU
        this.gameReset();
        this.proc.controller1 = new Application.Model.Controller.User();
        Application.Controller.add(this.proc.controller1);
        this.proc.pool1 = new Application.Model.Pool({
          controller: this.proc.controller1.id
        });
        Application.Pool.add(this.proc.pool1);
        this.proc.controller1.start();
        this.proc.controller2 = new Application.Model.Controller.AI({
          formula: CPU[0].FORMULA,
          smart: CPU[0].SMART - 20
        });
        Application.Controller.add(this.proc.controller2);
        this.proc.pool2 = new Application.Model.Pool({
          controller: this.proc.controller2.id
        });
        Application.Pool.add(this.proc.pool2);
        this.proc.controller2.start();
        this.proc.pool1.on('lines',
      spellCast,
      this.proc.pool1);
        return this.proc.pool2.on('lines',
      spellCast,
      this.proc.pool2);
      },
      function() {        //CPU vs CPU
        var actionDelay;
        actionDelay = 150;
        this.gameReset();
        this.proc.controller1 = new Application.Model.Controller.AI({
          formula: CPU[0].FORMULA,
          smart: CPU[0].SMART,
          actionDelay: actionDelay
        });
        Application.Controller.add(this.proc.controller1);
        this.proc.pool1 = new Application.Model.Pool({
          controller: this.proc.controller1.id
        });
        Application.Pool.add(this.proc.pool1);
        this.proc.controller1.start();
        this.proc.controller2 = new Application.Model.Controller.AI({
          formula: CPU[1].FORMULA,
          smart: CPU[1].SMART,
          actionDelay: actionDelay
        });
        Application.Controller.add(this.proc.controller2);
        this.proc.pool2 = new Application.Model.Pool({
          controller: this.proc.controller2.id
        });
        Application.Pool.add(this.proc.pool2);
        this.proc.controller2.start();
        this.proc.pool1.on('lines',
      spellCast,
      this.proc.pool1);
        return this.proc.pool2.on('lines',
      spellCast,
      this.proc.pool2);
      }
    ];

    Game.prototype.handler = {
      'change:mode': function(model, mode) {
        if (this.mode[mode] != null) {
          return this.mode[mode].apply(this);
        }
      }
    };

    return Game;

  }).call(this);

  Application.View.Game = (function() {
    //@gameReset()
    //@set 'status', STATUS.LOBBY
    //@gameStart()
    /*
     *   GAME VIEW
     */
    class Game extends Backbone.View {
      init() {
        var disabled;
        this.$('#jsSinglePlayGameOver .jsPlayAgain').click(function() {
          return Application.Game.switch(GAME_MODE.SINGLE_PLAYER);
        });
        this.$('#jsPlayerVsCpuGameOver .jsPlayAgain').click(function() {
          return Application.Game.switch(GAME_MODE.PLAYER_VS_CPU);
        });
        this.$('#jsCpuVsCpuGameOver .jsPlayAgain').click(function() {
          return Application.Game.switch(GAME_MODE.CPU_VS_CPU);
        });
        this.$('.jsExitToMenu, #jsControlMenu').click(function() {
          return Application.Game.switch(GAME_MODE.LOBBY);
        });
        $('body').keyup(function(e) {
          if (e.keyCode === 27) {
            return Application.Game.switch(GAME_MODE.LOBBY);
          }
        });
        disabled = 'button-disabled';
        this.$('#jsControlSound, #jsControlMusic').click(function() {
          var $this, id, turnOff;
          console.log("here");
          $this = $(this);
          $this.toggleClass(disabled);
          turnOff = $this.is(`.${disabled}`);
          id = $this.attr('id');
          Application.Sound.switchAudio(id === 'jsControlSound', !turnOff);
          return window.localStorage.setItem(id, turnOff);
        });
        return $(window).blur(function() {
          return Application.Pool.each(function(pool) {
            return pool.trigger('action', 'stop');
          });
        }).focus(function() {
          return Application.Pool.each(function(pool) {
            return pool.trigger('action', 'start');
          });
        });
      }

    };

    Game.prototype.node = '#jsGame';

    Game.prototype.mode = [
      function() {},
      //Loading
      function() {},
//Lobby
      function() {        //Application.switchView('Lobby')
        // Single player
        this.model.proc.view = new Application.View.Pool({
          x: 900 / 2 - 450 / 2,
          y: 50,
          model: this.model.proc.pool
        });
        this.$('#jsSinglePlay').html(this.model.proc.view.$el);
        this.model.proc.onGameOver = () => {
          Application.Sound.musicStop();
          this.$('#jsSinglePlayGameOver .jsScore').text(this.model.proc.pool.score);
          return this.$('#jsSinglePlayGameOver').css({
            opacity: 0,
            scale: 0
          }).show().transition({
            opacity: 1,
            scale: 1
          },
      VIEW_ANIMATE_TIME);
        };
        this.listenTo(this.model.proc.pool,
      'gameover',
      this.model.proc.onGameOver);
        return Application.Sound.musicPlay();
      },
      function() {        //PLayer vs CPU
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
        this.model.proc.onGameOver = () => {
          this.model.proc.pool1.trigger('action',
      'stop');
          this.model.proc.pool2.trigger('action',
      'stop');
          Application.Sound.musicStop();
          this.$('.jsGameOverWinLoose').hide();
          if (this.model.proc.pool1.score === this.model.proc.pool2.score) {
            this.$('.jsGameOverDraw').show();
          } else {
            if (this.model.proc.pool1.score >= this.model.proc.pool2.score) {
              this.$('.jsGameOverWin').show();
            } else {
              this.$('.jsGameOverLoose').show();
            }
          }
          this.$('#jsPlayerVsCpuGameOver .jsScore').text(this.model.proc.pool1.score);
          return this.$('#jsPlayerVsCpuGameOver').css({
            opacity: 0,
            scale: 0
          }).show().transition({
            opacity: 1,
            scale: 1
          },
      VIEW_ANIMATE_TIME);
        };
        this.listenTo(this.model.proc.pool1,
      'gameover',
      this.model.proc.onGameOver);
        this.listenTo(this.model.proc.pool2,
      'gameover',
      this.model.proc.onGameOver);
        return Application.Sound.musicPlay();
      },
      function() {        //CPU vs CPU
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
        this.model.proc.onGameOver = () => {
          this.model.proc.pool1.trigger('action',
      'stop');
          this.model.proc.pool2.trigger('action',
      'stop');
          Application.Sound.musicStop();
          this.$('.jsGameOverWinLoose').hide();
          if (this.model.proc.pool1.score === this.model.proc.pool2.score) {
            this.$('.jsGameOverDraw').show();
          } else {
            if (this.model.proc.pool1.score >= this.model.proc.pool2.score) {
              this.$('.jsGameOverCpu1').show();
            } else {
              this.$('.jsGameOverCpu2').show();
            }
          }
          this.$('#jsCpuVsCpuGameOver .jsScoreCpu1').text(this.model.proc.pool1.score);
          this.$('#jsCpuVsCpuGameOver .jsScoreCpu2').text(this.model.proc.pool2.score);
          return this.$('#jsCpuVsCpuGameOver').css({
            opacity: 0,
            scale: 0
          }).show().transition({
            opacity: 1,
            scale: 1
          },
      VIEW_ANIMATE_TIME);
        };
        this.listenTo(this.model.proc.pool1,
      'gameover',
      this.model.proc.onGameOver);
        this.listenTo(this.model.proc.pool2,
      'gameover',
      this.model.proc.onGameOver);
        return Application.Sound.musicPlay();
      }
    ];

    /*
    $('#jsChart').highcharts
        colors: ['#303090', '#903030']
        legend:
            enabled: false
        chart:
            type: 'line'
        title: null
        series: [
            {
                data: []
                name: 'CPU 1'
                marker:
                    enabled: false
            }
            {
                data: []
                name: 'CPU 2'
                marker:
                    enabled: false
            }
        ]
        yAxis:
            title: null

    #@model.proc.charts = $('#jsChart').highcharts()

    limit = 111150
    @model.proc.onNext1 = ->
        @model.proc.pool1.trigger 'gameover' if @model.proc.pool1.attributes.index>limit*2
        #@model.proc.charts.series[0].addPoint(@model.proc.pool1.score, true, @model.proc.charts.series[0].data.length>limit)

    @model.proc.onNext2 = ->
        @model.proc.pool2.trigger 'gameover' if @model.proc.pool2.attributes.index>limit*2
        #@model.proc.charts.series[1].addPoint(@model.proc.pool2.score, true, @model.proc.charts.series[1].data.length>limit)

    @listenTo @model.proc.pool1, 'nextShape', @model.proc.onNext1
    @listenTo @model.proc.pool2, 'nextShape', @model.proc.onNext2
     */
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
        }, _.once(() => {
          this.$('.game-inner').hide();
          this.mode[mode].apply(this);
          return $($gameInner[mode]).css({
            opacity: 0
          }).show().transition({
            opacity: 1
          }, delay);
        }, delay));
      }
    };

    return Game;

  }).call(this);

}).call(this);

//# sourceMappingURL=game.js.map
