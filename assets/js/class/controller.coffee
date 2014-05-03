class Application.Collection.Controller extends Backbone.Collection

### User keyboard control ###
class Application.Model.Controller.User extends Backbone.Model
    defaults:
        keys: {}
        delay: DROP_DELAY
        play: false

    pool: null

    setKey: (key, action)->
        Application.keyMapper @, key, action
        @attributes.keys[key] = action

    setKeys: (keys)->
        keys = [keys] if not _.isArray keys[0]
        @setKey(key[0], key[1]) for key in keys

    nextMove: =>
        @trigger('action','moveDown') if @get 'play'
        setTimeout(@nextMove, @attributes.delay)

    handler:
        action: (name, vars...)->
            @pool.trigger('action', name, vars) if (@attributes.play or name is ACTION.PAUSE) and @pool?

    ###
        setPath: (res)->
            @pool.shape.hint =
                x: res.x
                y: res.y
                angle: res.angle
    ###
    poolHandler:
        pause: ->
            @set 'play', !@attributes.play

        start: ->
            @set 'play', true

        stop: ->
            @set 'play', false

    ###
        nextShape: ->
            @action = []
            shape = @pool.shape.attributes
            Application.worker.postMessage
                trigger: 'findPlace'
                vars:
                    matrix: @pool.attributes.cells
                    shape: shape.shape
                    angle: shape.angle
                    shapeIndex: shape.index
                    x: shape.x
                    id: @id
    ###
    init: (keys)->
        @set 'id', Application.genId('Controller')

        keys = [
            [KEY.LEFT, ACTION.MOVE_LEFT]
            [KEY.RIGHT, ACTION.MOVE_RIGHT]
            [KEY.DOWN, ACTION.MOVE_DOWN]
            [KEY.UP, ACTION.ROTATE_RIGHT]
            [KEY.SPACE, ACTION.DROP]
            [KEY.P, ACTION.PAUSE]
            [KEY.ENTER, ACTION.GET_SCORE]
        ] if not keys?

        @setKeys(keys)
        @nextMove()



##############################
#
#
# AI controller
#
#
##############################

class Application.Model.Controller.AI extends Backbone.Model
    defaults:
        delay: DROP_DELAY
        actionDelay: 400
        play: false
        formula: 1000
        smart: 1

    pool: null
    action:[]

    timeout: null

    timer: =>
        if @get 'play'
            @trigger('action','moveDown')
            @timeout = setTimeout(@timer, @attributes.delay)

    timerStop: ->
        clearTimeout(@timeout)

    nextAction: =>
        if @attributes.play and @action.length
            action = @action.shift()
            @trigger 'action', action

        delayShift = @attributes.actionDelay/2
        setTimeout(@nextAction, rand(@attributes.actionDelay-delayShift, @attributes.actionDelay+delayShift))

    findPlace: ->
        @action = []
        shape = @pool.shape.attributes
        Application.worker.postMessage
            trigger: 'findPlace'
            vars:
                matrix: @pool.attributes.cells
                shape: shape.shape
                angle: shape.angle
                shapeIndex: shape.index
                x: shape.x
                id: @id
                formula: @attributes.formula
                smart: @attributes.smart

    handler:
        action: (name, vars...)->
            @pool.trigger('action', name, vars) if (@attributes.play or name is ACTION.PAUSE) and @pool?

        setPath: (result)->
            #_dump result
            @action = result.path

        'change:play':->
            @findPlace() if @get 'play'

    poolHandler:
        pause: ->
            @set 'play', !@attributes.play

        start: ->
            @set 'play', true

        stop: ->
            @set 'play', false

        putShape: ->
            @timerStop()

        nextShape: ->
            if @get 'play'
                @findPlace()
                @timer()

    init: (params)->
        @set 'id', Application.genId('Controller')
        console.log "FORMULA: #{@attributes.formula}, SMART: #{@attributes.smart}"
        @timer()
        @nextAction()



###

    OLD AI wiout delay control

###

class Application.Model.Controller.AI_OLD extends Backbone.Model
    defaults:
        delay: DROP_DELAY
        actionDelay: 150
        play: false

    pool: null
    action:[]

    nextMove: =>
        _dump @get 'play'
        @trigger('action','moveDown') if @get 'play'
        setTimeout(@nextMove, @attributes.delay)

    nextAction: =>
        if @attributes.play and @action.length
            action = @action.shift()
            @trigger 'action', action

        setTimeout(@nextAction, rand(@attributes.actionDelay, @attributes.actionDelay))

    findPlace: ->
        @action = []
        shape = @pool.shape.attributes
        Application.worker.postMessage
            trigger: 'findPlace'
            vars:
                matrix: @pool.attributes.cells
                shape: shape.shape
                angle: shape.angle
                shapeIndex: shape.index
                x: shape.x
                id: @id

    handler:
        action: (name, vars...)->
            @pool.trigger('action', name, vars) if (@attributes.play or name is ACTION.PAUSE) and @pool?

        setPath: (result)->
            #_dump result
            @action = result.path

        'change:play':->
            @findPlace() if @get 'play'

    poolHandler:
        pause: ->
            @set 'play', !@attributes.play

        start: ->
            @set 'play', true

        stop: ->
            @set 'play', false

        nextShape: ->
            @findPlace() if @get 'play'


    init: ()->
        @set 'id', Application.genId('Controller')
        @nextMove()
        @nextAction()