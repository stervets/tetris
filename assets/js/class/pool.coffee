### Game pool ###
class Application.Model.Pool extends Backbone.Model
    defaults:
        index: 0 #shape index in shapeArray
        cells: []
        w: POOL.WIDTH
        h: POOL.HEIGHT

    score: 0

    shape: null
    next: null
    locked: false
    combo: 0

    controller: null

    nextShape: ->
        if @next.attributes.shape?
            @shape.setShape @next.attributes.index, @next.attributes.angle

            next = Application.shapeStack.getShape(@attributes.index+1)
            @next.setShape next.index, next.angle
        else
            shape = Application.shapeStack.getShape(@attributes.index)
            @shape.setShape shape.index, shape.angle
            next = Application.shapeStack.getShape(@attributes.index+1)
            @next.setShape next.index, next.angle

        @shape.attributes.drop = -1
        @shape.key = Application.genId('Shape')
        @worker 'checkDrop'
        @attributes.index++
        @locked = false

    resetCells: ->
        @trigger 'action', 'stop'
        cells = []
        line = (0 for i in [0...@attributes.w])
        cells.push(line[..]) for i in [0...@attributes.h]
        @attributes.cells = cells
        @trigger 'action', 'nextShape'


    setShapeXY: (x,y)->
        return if @locked
        @shape.set
            x: x
            y: y

    worker: (trigger, angle)->
        atr = @attributes
        angle = @shape.attributes.angle if not angle?

        Application.worker.postMessage
            trigger: trigger
            vars:
                matrix: atr.cells
                shape: @shape.attributes.shape[angle]
                x: @shape.attributes.x
                y: @shape.attributes.y
                id: @id
                key: @shape.key

    actions:

        doMoveDown: ->
            return if @locked
            @shape.set 'y', @shape.attributes.y+1

        doMoveLeft: ->
            return if @locked
            @shape.set 'x', @shape.attributes.x-1
            @worker 'checkDrop'

        doMoveRight: ->
            return if @locked
            @shape.set 'x', @shape.attributes.x+1
            @worker 'checkDrop'

        doRotateLeft: ->
            return if @locked
            angle = @shape.attributes.angle - 1
            angle = 3 if angle<0
            @shape.set 'angle', angle
            @worker 'checkDrop'

        doRotateRight: ->
            return if @locked
            angle = @shape.attributes.angle + 1
            angle = 0 if angle>3
            @shape.set 'angle', angle
            @worker 'checkDrop'

        moveDown: ->
            return if @locked
            @worker 'checkMoveDown'

        moveLeft: ->
            return if @locked
            @worker 'checkMoveLeft'

        moveRight: ->
            return if @locked
            @worker 'checkMoveRight'

        rotateLeft: ->
            return if @locked
            Application.Sound.play(RES.AUDIO.SHAPE_ROTATE)
            angle = @shape.attributes.angle - 1
            angle = 3 if angle<0
            @worker 'checkRotateLeft', angle

        rotateRight: ->
            return if @locked
            Application.Sound.play(RES.AUDIO.SHAPE_ROTATE)
            angle = @shape.attributes.angle + 1
            angle = 0 if angle>3
            @worker 'checkRotateRight', angle

        drop: ->
            return if @locked
            #if @shape.attributes.drop < 0
            #    @worker 'checkMoveDown'
            #else
            @locked = true
            @worker 'setDrop'

        lines: ->
            Application.Sound.play(RES.AUDIO.LINES)
            @trigger 'lines'

        putShape: ->
            @locked = true
            Application.Sound.play(RES.AUDIO.SHAPE_DROP)
            @worker 'putShape'

        nextShape: ->
            @nextShape()
            @trigger 'nextShape'

        overflow: ->
            @trigger 'action', 'stop'
            @trigger 'gameover'

        onPutShape: ->
            @worker 'process'

        getScore: ->
            @worker 'getScore'

        reset: ->
            @resetCells()

    handler:
        action: (name, vars...)->
            @actions[name].apply(@, vars) if @actions[name]?
            @controller.poolHandler[name].apply(@controller, vars) if @controller.poolHandler[name]?

        actionCallback: (tick, name, result) ->

    init: (params)->
        controller = Application.Controller.get(params.controller)
        throw new Error('Controller must be set') if not controller?

        controller.pool = @
        @controller = controller

        @set 'id', Application.genId('Pool')

        @shape = new Application.Model.Shape()
        @next = new Application.Model.Shape()

        #@trigger 'action', 'start'


### Game pool collection ###
class Application.Collection.Pool extends Backbone.Collection
    model: Application.Model.Pool
