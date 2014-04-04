###
    Shape view
###
class Application.View.Shape extends Backbone.View
    $shape: null
    prevAngle: 0
    angle: 0
    lastTime: 0

    modelHandler:
        'change:x change:y change:angle': ->
            return if not @$shape

            shape = @model.attributes
            transition =
                left: shape.x * POOL.CELL_SIZE
                top: shape.y * POOL.CELL_SIZE

            if @model.changed.angle?
                transition.rotate = if shape.angle>@prevAngle or (@prevAngle is 3 and shape.angle is 0) then '+=90deg' else '-=90deg'
                @prevAngle = @model.changed.angle

            time = new Date().getTime()
            timeSub = time - @lastTime
            timeSub = ANIMATE_TIME if timeSub>ANIMATE_TIME
            #@$shape.stop(true, false).transition transition, timeSub
            @$shape.stop(true, false).transition transition, ANIMATE_TIME, 'out'
            @lastTime = time

        setShape: ->
            shape = @model.attributes
            @$shape = $(Application.shapesView[shape.index][0])
            @prevAngle = shape.angle
            @$shape.stop().css
                left: shape.x * POOL.CELL_SIZE
                top: shape.y * POOL.CELL_SIZE
                rotate: shape.angle * 90

            @$el.html @$shape

            @lastTime = new Date().getTime()

    initialize: ->
        for event, handler of @modelHandler
            @listenTo @model, event, handler


######################
#
# Pool view
#
######################
class Application.View.Pool extends Backbone.View
    template: 'tplPool'

    shapeView: null
    $body: null
    $score: null
    $cells: null


    addShape: ()->
        $cells = @$cells
        shape = @shapeView.model.attributes
        return if shape.y<0 or shape.y-shape.shape.length > $cells.length
        $shape = $($(Application.shapesView[shape.index][shape.angle]).html())
        $shape.css
            left: "+=#{shape.x * POOL.CELL_SIZE}px"
            top: "+=#{shape.y * POOL.CELL_SIZE}px"
        @$body.append($shape)
        for node in $shape by 2
            $cells[Math.floor(node.offsetTop/POOL.CELL_SIZE)][Math.floor(node.offsetLeft/POOL.CELL_SIZE)] = $(node)
        null


    poolHandler:
        onPutShape:()->
            @addShape()

        overflow: ()->
            console.log 'overlow at view'
            @addShape()

        lines: (lines, score)->
            #@$head.text(score)
            @$score.text(score)

            $cells = @$cells
            transit = {}
            for line, index in lines
                for $cell, x in $cells[line]
                    $cell.transition({scale: 0}, ANIMATE_TIME, do($cell)->
                                    -> $cell.remove())
                    $cells[line][x] = null

                    for y in [line-1..0] when $cells[y][x]
                        key = y*POOL.WIDTH+x
                        transit[key] = {node:$cells[y][x], top: 0} if not transit[key]?
                        transit[key].top+=POOL.CELL_SIZE

            for line in lines
                for $cell, x in $cells[line]
                    for y in [line-1..0] when $cells[y][x]
                        [$cells[y+1][x], $cells[y][x]] = [$cells[y][x], $cells[y+1][x]]

            for key, cell of transit
                cell.node.transition({top: '+='+cell.top}, ANIMATE_TIME)
            null

    modelHandler:
        action: (name, vars)->
            @poolHandler[name].apply(@, vars) if @poolHandler[name]?

    init: (params)->
        @$cells = Application.matrixEmpty(POOL.WIDTH, POOL.HEIGHT, null)

        @$el.css
            left: params.x
            top: params.y

        @$body = @$('.jsPoolBody')
        @$score = @$('.jsPoolScore')

        @shapeView = new Application.View.Shape
            model: @model.shape

        @$body.append @shapeView.$el

        @model.trigger 'action', 'reset'
        @model.trigger 'action', 'start'