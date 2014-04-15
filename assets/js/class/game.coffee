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
        Application.Pool.reset()
        Application.Controller.reset()
        Application.shapeStack.reset()
        Application.shapeStack.generateShapes(4)

    gameStart: ->
        ###
        controller = new Application.Model.Controller.User()
        #controller = new Application.Model.Controller.AI
        #    formula: 2
        Application.Controller.add(controller)

        pool = new Application.Model.Pool
            controller: controller.id

        Application.Pool.add(pool)

        if INIT_TEST_VIEW
            view = new Application.View.Pool
                x: 0
                y: 50
                model: pool
            $('body').append view.$el


        #controller = new Application.Model.Controller.User()
        controller2 = new Application.Model.Controller.AI
            formula: 2
        Application.Controller.add(controller2)

        pool2 = new Application.Model.Pool
            controller: controller2.id

        Application.Pool.add(pool2)

        if INIT_TEST_VIEW
            view2 = new Application.View.Pool
                x: 450
                y: 50
                model: pool2
            $('body').append view2.$el
        ###
    switch: (mode)-> if @attributes.mode is mode then @trigger 'change:mode', @, mode else @set 'mode', mode

    mode: [
        #Lobby
        ->

        # Single player
        ->
            @gameReset()
            @proc.controller = new Application.Model.Controller.User()
            Application.Controller.add(@proc.controller)
            @proc.pool = new Application.Model.Pool
                controller: @proc.controller.id
            Application.Pool.add(@proc.pool)
    ]

    handler:
        'change:mode': (model, mode)-> @mode[mode].apply @ if @mode[mode]?

        showLobby: ->
            #Application.switchView('Lobby')
            #@trigger 'singlePlayer'

        singlePlayer: ->



            #$('body').append view.$el

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


###

    controller = new Application.Model.Controller.User()

    #controller = new Application.Model.Controller.AI
    #    formula: 3

    Application.Controller.add(controller)

    pool = new Application.Model.Pool
        controller: controller.id

    Application.Pool.add(pool)

    if INIT_TEST_VIEW
        view = new Application.View.Pool
            x: 0
            y: 50
            model: pool
        $('body').append view.$el


    controller2 = new Application.Model.Controller.AI
        formula: 2

    Application.Controller.add(controller2)

    pool2 = new Application.Model.Pool
        controller: controller2.id

    Application.Pool.add(pool2)

    if INIT_TEST_VIEW
        view2 = new Application.View.Pool
            x: 430
            y: 50
            model: pool2
        $('body').append view2.$el



    controller3 = new Application.Model.Controller.AI
        formula: 6

    Application.Controller.add(controller3)

    pool3 = new Application.Model.Pool
        controller: controller3.id

    Application.Pool.add(pool3)

    if INIT_TEST_VIEW
        view3 = new Application.View.Pool
            x: 860
            y: 50
            model: pool3
        $('body').append view3.$el

###