###
    Shape view
###
class Application.View.Shape extends Backbone.View
    $shape: null
    $drop: null

    prevAngle: 0
    angle: 0
    lastTime: 0

    modelHandler:
        'change:drop': ->
            @$drop.css
                top: @model.attributes.drop * POOL.CELL_SIZE
                opacity: DROP_SHAPE_OPACITY

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
            @$shape.css transition
            transition.top = shape.drop * POOL.CELL_SIZE
            transition.opacity = DROP_SHAPE_OPACITY
            @$drop.css transition

            @lastTime = time

        setShape: ->
            shape = @model.attributes
            @$shape = $(Application.shapesView[shape.index][0])
            @prevAngle = shape.angle

            css =
                left: shape.x * POOL.CELL_SIZE
                top: shape.y * POOL.CELL_SIZE
                rotate: shape.angle * 90

            @$shape.css css

            @$drop = $(Application.shapesView[shape.index][0])
            css.top = 0
            css.opacity = 0
            @$drop.css css

            @$el.html @$shape
            @$el.append @$drop

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
    $next: []
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
            shape = Application.shapeStack.getShape(@model.attributes.index+3)
            @$next[0].html(@$next[1].html())
            @$next[1].html(@$next[2].html())
            @$next[2].html(Application.shapesView[shape.index][shape.angle])
            @addShape()

        overflow: ()->
            #console.log 'overlow at view'
            #@addShape()

        lines: (lines, score)->
            @$score.text(score)

            $cells = @$cells
            transit = {}
            for line, index in lines
                for $cell, x in $cells[line]
                    $cell.css scale: 0
                    _.delay ($cell)->
                            $cell.remove()
                        ,ANIMATE_TIME
                        ,$cell

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
                cell.node.css top: '+='+cell.top
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

        @$('.jsShapeNext').css
            scale: 0.5

        for index in [0..2]
            @$next.push(@$(".jsShapeNext#{index}"))
            shape = Application.shapeStack.getShape(index+1)
            @$next[index].html(Application.shapesView[shape.index][shape.angle])

        @$body.append @shapeView.$el

        @model.trigger 'action', 'reset'
        @model.trigger 'action', 'start'