class Application.Model.Player extends Backbone.Model
    defaults:
        name: 'PLayer'
        rating: 0

class Application.Model.Game extends Backbone.Model
    defaults:
        mode: null

    proc: {}

    gameReset: ->
        @proc = {}
        Application.shapeStack.reset()
        Application.shapeStack.generateShapes(4)
        Application.Pool.reset()
        Application.Controller.reset()

    switch: (mode)-> if @attributes.mode is mode then @trigger 'change:mode', @, mode else @set 'mode', mode

    mode: [
        #Lobby
        ->

        # Single player
        ->
            @gameReset()
            #@proc.controller = new Application.Model.Controller.User()
            @proc.controller = new Application.Model.Controller.AI
                formula: 2

            Application.Controller.add(@proc.controller)
            @proc.pool = new Application.Model.Pool
                controller: @proc.controller.id
            Application.Pool.add(@proc.pool)


            return;
            #controller = new Application.Model.Controller.User()
            controller = new Application.Model.Controller.AI
                formula: 2
            Application.Controller.add(controller)

            pool = new Application.Model.Pool
                controller: controller.id

            Application.Pool.add(pool)

            if INIT_TEST_VIEW
                view = new Application.View.Pool
                    x: 800
                    y: 50
                    model: pool
                $('#jsPoolTest').append view.$el
    ]

    handler:
        'change:mode': (model, mode)-> @mode[mode].apply @ if @mode[mode]?

    init: ->
        #@gameReset()
        #@set 'status', STATUS.LOBBY
        #@gameStart()

class Application.View.Game extends Backbone.View
    node: '#jsGame'

    mode: [
        #Lobby
        ->
            #Application.switchView('Lobby')
        # Single player
        ->
            @model.proc.view = new Application.View.Pool
                x: 900/2 - 450/2
                y: 50
                model: @model.proc.pool

            @$('#jsSinglePlay').html(@model.proc.view.$el)

            @model.proc.onGameOver = =>
                Application.Sound.musicStop()
                @$('#jsSinglePlayGameOver .jsScore').text(@model.proc.pool.lines)
                @$('#jsSinglePlayGameOver')
                .css
                    opacity: 0
                    scale: 0
                .show()
                .transition
                    opacity: 1
                    scale: 1
                    , VIEW_ANIMATE_TIME

            @listenTo @model.proc.pool, 'gameover', @model.proc.onGameOver
            Application.Sound.musicPlay()
    ]

    modelHandler:
        change: ->

        'change:mode': (model, mode)->
            if @mode[mode]?
                delay = if @$('.game-inner:visible').length then VIEW_ANIMATE_TIME else 0
            $gameInner = @$('.game-inner')
            $gameInner.transition
                opacity: 0
                , _.once =>
                    @$('.game-inner').hide()
                    @mode[mode].apply @

                    $($gameInner[mode])
                    .css
                        opacity: 0
                    .show()
                    .transition opacity: 1, delay
                , delay

        menuShow: ->

        singlePlayer: ->

    init: ->
        @$('#jsSinglePlayGameOver .jsPlayAgain')
            .click ->
                    Application.Game.gameReset()
                    Application.Game.switch(GAME_MODE.SINGLE_PLAYER)
