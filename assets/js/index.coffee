Application.shapes = []
Application.Model.Controller = {}


Application.matrixEmpty = (width, height, val=0)->
    line = (val for _dummy in [0...width])
    matrix = []
    matrix.push(line[..]) for _dummy in [0...height]
    matrix

Application.lineCopy = (source, value)->
    line = []
    if value?
        line.push(if val then value else 0) for val in source
    else
        line = source[..]
    line

Application.matrixCopy = (source, value)->
        matrix = []
        matrix.push(if value? then Application.lineCopy(line, value) else line[..]) for line in source
        matrix

### Generate rotated shapes and align ###
Application.initShapes = ->
    matrixRot90 = (source)->
        matrix = Application.matrixCopy(source)
        len = matrix.length-1
        for row, i in source
            for cell, j in row
                matrix[j][len-i] = source[i][j]
        matrix

    getShapeMatrix = (shape)->
        shapeWidth = shape[0].length
        lineStart = Math.floor(shapeWidth/2 - shape.length/2)
        matrix = []
        for line in [0...shapeWidth]
            matrix.push(if line >= lineStart and line-lineStart<shape.length then shape[line-lineStart] else (0 for _dummy in [0...shapeWidth]))
        matrix

    for shape, num in SHAPES
        matrix = Application.shapes[num] = []
        matrix[0] = getShapeMatrix(shape)
        matrix[1] = matrixRot90(matrix[0])
        matrix[2] = matrixRot90(matrix[1])
        matrix[3] = matrixRot90(matrix[2])

Application.shapesView = []
Application.initShapesView =->
    for shapes, index in Application.shapes
        Application.shapesView.push []
        for shape in shapes
            $shape = $(Application.Templates.tplShape()).css
                width: shape.length * POOL.CELL_SIZE
                height: shape.length * POOL.CELL_SIZE

            for line, y in shape
                for val, x in line when val
                    $shape.append Application.Templates.tplCell
                            top: y * POOL.CELL_SIZE
                            left: x * POOL.CELL_SIZE
                            index: index+1
            Application.shapesView[index].push $shape[0].outerHTML

### Main shapes stack ###
class Application.Model.ShapeStack extends Backbone.Model
    defaults:
        shapes: []

    reset: ->
        #@set 'shapes', []

    getShape: (index)->
        len = index - @attributes.shapes.length + 2
        @generateShapes(len) if len>0

        {
            index: @attributes.shapes[index][0]
            angle: @attributes.shapes[index][1]
        }

    generateShapes: (num)->
        for i in [0...num]
            shape = rand(SHAPES.length-1)
            #shape = if rand(1) then 4 else 4
            #shape = if rand(1) then 5 else 6
            maxAngle = SHAPE_ANGLES[shape] || 4
            @attributes.shapes.push([shape, rand(maxAngle-1)])
        #@attributes.shapes.push([rand(0,4), rand(maxAngle-1)]) for i in [0...num]
        #@attributes.shapes.push([4, 0]) for i in [0...num]

    init: ()->
        @generateShapes(250)
        return;
        key = 'shapes'
        if data = window.localStorage.getItem(key)
            @attributes.shapes = JSON.parse(data)
        else
            @generateShapes(350)
            window.localStorage.setItem(key, JSON.stringify(@attributes.shapes))

### Shape model ###
class Application.Model.Shape extends Backbone.Model
    defaults:
        index: 0
        angle: 0
        x: 0
        y: 0
        drop: -1
        shape: null
        size: 0

    setShape: (index, angle=0)->
        size = Application.shapes[index][0].length
        @set
            index: index
            shape: Application.shapes[index]
            size: size
            angle: angle
            x: Math.floor(POOL.WIDTH/2 - size/2)
            y: -size
        @trigger('setShape')

# Application keymap
Application.keyMap = {}

# Key Mapper
Application.keyMapper = (controller, key, action)->
    Application.keyMap[key] =
        controller: controller
        action: action

### Hook keys ###
Application.hook = ->
    $(window).focus ->
        $(document).focus()

    $(document).keydown (e)->
        map = Application.keyMap[e.keyCode]
        if map?
            map.controller.trigger 'action', map.action
            e.preventDefault()

###
Application.switchView = (viewName)->
    view.trigger('hide') for name, view of Application.GameView when viewName isnt name
    Application.GameView[viewName].trigger('showDelay')
###

Application.switchView = (viewName)->
    view.trigger('hide') for name, view of Application.GameView when viewName isnt name
    Application.GameView[viewName].trigger('showDelay')


# append show\hide listeners and handler to view
Application.appendShowHide = (view)->
    view.$el.hide()
    view.visible = false

    view.onShow = ->
        @visible = true
        @$el
            .css
                opacity: 0
            .show()
            .transition
                opacity: 1
                , VIEW_ANIMATE_TIME

    view.onShowDelay = ->
        _.delay((view)->
                    view.trigger 'show'
               ,VIEW_ANIMATE_TIME
               , @)

    view.onHide = ->
        @visible = false
        @$el
        .transition
                opacity: 0
                , VIEW_ANIMATE_TIME
                , =>
                    @$el.hide()

    view.on 'show', view.onShow
    view.on 'showDelay', view.onShowDelay
    view.on 'hide', view.onHide

# Create menu collection
Application.createMenu = (menuTitle, menuItems, context)->
    menu = new Application.Collection.Menu()
    menu.setTitle menuTitle
    menuView = new Application.View.Menu
        collection:
            Menu: menu

    context = menu if not context?
    #_dump(menuView.$el[0].outerHTML)

    #$menuNode = menuView.$('.jsMenuItems')
    for title, trigger of menuItems
        menuItem = new Application.Model.MenuItem
            title: title
            triggerHandler: trigger
            context: context
        menu.add menuItem

    {
        collection: menu
        view: menuView
    }

Application.clearCollection = (collection)->
    while collection.length>0
        model = collection.at 0
        collection.remove model
        model.trigger('destroy')

### Start application ###
Application.onStart ->
    $('head').append Application.Templates.tplStyle
        POOL: POOL
        poolWidth: POOL.WIDTH * POOL.CELL_SIZE
        poolHeight: POOL.HEIGHT * POOL.CELL_SIZE

    Application.initShapes();
    Application.initShapesView();

    Application.shapeStack = new Application.Model.ShapeStack()
    Application.Pool = new Application.Collection.Pool()
    Application.Controller = new Application.Collection.Controller()
    Application.Sound = new Application.Collection.Sound()

    Application.GameView = {}

    Application.Lobby = new Application.Model.Lobby()
    Application.GameView.Lobby = new Application.View.Lobby
        model: Application.Lobby

    Application.Game = new Application.Model.Game()
    Application.GameMainView = new Application.View.Game
        model: Application.Game

    Application.appendShowHide(Application.GameView[name]) for name of Application.GameView

    Application.hook()
    Application.Game.switch(GAME_MODE.LOBBY)