class Application.Model.Player extends Backbone.Model
    defaults:
        name: 'PLayer'
        rating: 0

STATUS =
    LOBBY: 0
    GAME: 1



class Application.Model.Game extends Backbone.Model
    defaults:
        status: STATUS.LOBBY

    gameReset: ->
        Application.Pool.reset()
        Application.Controller.reset()
        Application.shapeStack.reset()
        console.log('game reseted')

    handler:
        menuShow: ->
            @gameReset()

    init: ->
        @trigger 'menuShow'


class Application.View.Game extends Backbone.View
    node: '#jsGame'
    modelHandler:
        change: ->

        menuShow: ->

    init: ->
        @$el.html('asdadss')

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