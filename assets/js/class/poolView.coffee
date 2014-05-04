###
    Shape view
###
class Application.View.Shape extends Backbone.View
    $shape: null
    $drop: null

    prevAngle: 0
    angle: 0
    lastTime: 0

    appendDrop: ->
        shape = @model.attributes
        @$drop = $(Application.shapesView[shape.index][0])
        css =
            left: shape.x * POOL.CELL_SIZE
            top: shape.drop * POOL.CELL_SIZE
            rotate: shape.angle * 90
            opacity: 0
        @$drop.css css
        @$el.append @$drop

    modelHandler:
        'change:drop': ->
                if @$drop?
                    @$drop.css
                        top: @model.attributes.drop * POOL.CELL_SIZE
                        opacity: DROP_SHAPE_OPACITY
                else
                    @appendDrop()


        'change:x change:y change:angle': ->
            return if not @$shape

            shape = @model.attributes
            transition =
                left: shape.x * POOL.CELL_SIZE
                top: shape.y * POOL.CELL_SIZE

            if @model.changed.angle?
                transition.rotate = if shape.angle>@prevAngle or (@prevAngle is 3 and shape.angle is 0) then '+=90deg' else '-=90deg'
                @prevAngle = @model.changed.angle

            @$shape.css transition

            if @$drop?
                transition.top = shape.drop * POOL.CELL_SIZE
                transition.opacity = DROP_SHAPE_OPACITY
                @$drop.css transition

        setShape: ->
            shape = @model.attributes
            @$shape = $(Application.shapesView[shape.index][0])
            @prevAngle = shape.angle

            css =
                left: shape.x * POOL.CELL_SIZE
                top: shape.y * POOL.CELL_SIZE
                rotate: shape.angle * 90

            @$shape.css css

            if @$drop?
                @$drop.remove()
                @$drop = null

            @$el.html @$shape

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
    #particle: null

    addShape: ()->
        $cells = @$cells
        shape = @shapeView.model.attributes
        return if shape.y<0 or shape.y-shape.shape.length > $cells.length

        $shape = $($(Application.shapesView[shape.index][shape.angle]).html())
        $shape
            .css
                left: "+=#{shape.x * POOL.CELL_SIZE}px"
                top: "+=#{shape.y * POOL.CELL_SIZE}px"


        #_dump shape
        #@particle.setXY shape.x * POOL.CELL_SIZE + $shape.width(), shape.drop * POOL.CELL_SIZE+ $shape.height()
        #@particle.start()

        @$body.append($shape)

        for node in $shape by 2
            $node = $(node)
            pos = $node.position()
            $cells[Math.floor(pos.top/POOL.CELL_SIZE)][Math.floor(pos.left/POOL.CELL_SIZE)] = $node.data('shapeIndex', shape.index)
            #$cells[Math.floor(node.offsetTop/POOL.CELL_SIZE)][Math.floor(node.offsetLeft/POOL.CELL_SIZE)] = $(node).data('shapeIndex', shape.index)
            #$cells[Math.floor($(node).position().top/POOL.CELL_SIZE)][Math.floor($(node).position().left/POOL.CELL_SIZE)] = $(node).data('shapeIndex', shape.index)
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

        lines: (lines, score, combo = 0)->
            @$score.text(score)

            $cells = @$cells
            transit = {}
            #_dump lines
            for line, index in lines
                for $cell, x in $cells[line]

                    $cell.css
                        scale: 0

                    _.delay (x,y,particle, color)->
                            particle.launch x*POOL.CELL_SIZE, y, color, (x+(x-POOL.WIDTH/2))*POOL.CELL_SIZE
                        ,100
                        ,x
                        ,line*POOL.CELL_SIZE
                        ,@particle
                        ,$cell.data('shapeIndex')

                    #$cell.remove()
                    _.delay ($cell)->
                            $cell.remove()
                        ,ANIMATE_TIME
                        ,$cell

                    $cells[line][x] = null
                    for y in [line...0] when $cells[y][x] or $cells[y-1][x]
                        _.delay ($cell, y)->
                                $cell.css top: y
                            ,100, $cells[y-1][x], y*POOL.CELL_SIZE
                        #$cells[y-1][x].css top: y*POOL.CELL_SIZE
                        [$cells[y-1][x], $cells[y][x]] = [$cells[y][x], $cells[y-1][x]]
            @particle.message "Combo x#{combo}", lines[0]*POOL.CELL_SIZE, combo if combo>1
            null

    modelHandler:
        action: (name, vars)->
            @poolHandler[name].apply(@, vars) if @poolHandler[name]?

    init: (params)->
        @$next = []
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
            @$next[index] = @$(".jsShapeNext#{index}")
            shape = Application.shapeStack.getShape(index+1)
            @$next[index].html(Application.shapesView[shape.index][shape.angle])

        @$body.append @shapeView.$el



        @particle = new Application.Particle
        _.delay (view)->
                    pos = view.$body.position()
                    #_dump pos
                    view.particle.params.x = pos.left
                    view.particle.params.y = pos.top
                    #_dump view.particle
                ,500, @
        #    stopTime: 100
        #    lifetime: 100
        #    distance: 30

        @$el.append @particle.$el

        @model.trigger 'action', 'reset'
        @model.trigger 'action', 'start'