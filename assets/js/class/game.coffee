class Application.Model.Player extends Backbone.Model
    defaults:
        name: 'PLayer'
        rating: 0

###
#   GAME MODEL
###
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
            @gameReset()

        # Single player
        ->
            @gameReset()
            @proc.controller = new Application.Model.Controller.User()
            #@proc.controller = new Application.Model.Controller.AI
            #    formula: 2

            Application.Controller.add(@proc.controller)
            @proc.pool = new Application.Model.Pool
                controller: @proc.controller.id
            Application.Pool.add(@proc.pool)

        #PLayer vs CPU
        ->
            @gameReset()
            @proc.controller1 = new Application.Model.Controller.User()

            Application.Controller.add(@proc.controller1)
            @proc.pool1 = new Application.Model.Pool
                controller: @proc.controller1.id
            Application.Pool.add(@proc.pool1)

            @proc.controller2 = new Application.Model.Controller.AI
                formula: 2
            Application.Controller.add(@proc.controller2)
            @proc.pool2 = new Application.Model.Pool
                controller: @proc.controller2.id
            Application.Pool.add(@proc.pool2)

        #CPU vs CPU
        ->
            actionDelay = 100
            @gameReset()
            @proc.controller1 = new Application.Model.Controller.AI
                formula: CPU_FORMULA.CPU1
                actionDelay: actionDelay
            Application.Controller.add(@proc.controller1)
            @proc.pool1 = new Application.Model.Pool
                controller: @proc.controller1.id
            Application.Pool.add(@proc.pool1)

            @proc.controller2 = new Application.Model.Controller.AI
                formula: CPU_FORMULA.CPU2
                actionDelay: actionDelay
            Application.Controller.add(@proc.controller2)
            @proc.pool2 = new Application.Model.Pool
                controller: @proc.controller2.id
            Application.Pool.add(@proc.pool2)

    ]

    handler:
        'change:mode': (model, mode)-> @mode[mode].apply @ if @mode[mode]?

    init: ->
        #@gameReset()
        #@set 'status', STATUS.LOBBY
        #@gameStart()

###
#   GAME VIEW
###
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

        #PLayer vs CPU
        ->
            @model.proc.view1 = new Application.View.Pool
                x: 450/2 - 450/2
                y: 50
                model: @model.proc.pool1
            @$('#jsPlayerVsCpu').html(@model.proc.view1.$el)

            @model.proc.view2 = new Application.View.Pool
                x: 1350/2 - 450/2
                y: 50
                model: @model.proc.pool2
            @$('#jsPlayerVsCpu').append(@model.proc.view2.$el)

            @model.proc.onGameOver = =>
                @model.proc.pool1.trigger 'action', 'stop'
                @model.proc.pool2.trigger 'action', 'stop'

                Application.Sound.musicStop()
                @$('.jsGameOverWinLoose').hide()

                if @model.proc.pool1.lines == @model.proc.pool2.lines
                    @$('.jsGameOverDraw').show()
                else
                    if @model.proc.pool1.lines>=@model.proc.pool2.lines
                        @$('.jsGameOverWin').show()
                    else
                        @$('.jsGameOverLoose').show()

                @$('#jsPlayerVsCpuGameOver .jsScore').text(@model.proc.pool1.lines)
                @$('#jsPlayerVsCpuGameOver')
                .css
                        opacity: 0
                        scale: 0
                .show()
                .transition
                        opacity: 1
                        scale: 1
                        , VIEW_ANIMATE_TIME

            @listenTo @model.proc.pool1, 'gameover', @model.proc.onGameOver
            @listenTo @model.proc.pool2, 'gameover', @model.proc.onGameOver
            Application.Sound.musicPlay()

        #CPU vs CPU
        ->
            @model.proc.view1 = new Application.View.Pool
                x: 450/2 - 450/2
                y: 50
                model: @model.proc.pool1
            @$('#jsCpuVsCpu').html(@model.proc.view1.$el)

            @model.proc.view2 = new Application.View.Pool
                x: 1350/2 - 450/2
                y: 50
                model: @model.proc.pool2
            @$('#jsCpuVsCpu').append(@model.proc.view2.$el)

            @model.proc.onGameOver = =>
                @model.proc.pool1.trigger 'action', 'stop'
                @model.proc.pool2.trigger 'action', 'stop'

                Application.Sound.musicStop()
                @$('.jsGameOverWinLoose').hide()

                if @model.proc.pool1.lines == @model.proc.pool2.lines
                    @$('.jsGameOverDraw').show()
                else
                    if @model.proc.pool1.lines>=@model.proc.pool2.lines
                        @$('.jsGameOverCpu1').show()
                    else
                        @$('.jsGameOverCpu2').show()

                @$('#jsCpuVsCpuGameOver .jsScoreCpu1').text(@model.proc.pool1.lines)
                @$('#jsCpuVsCpuGameOver .jsScoreCpu2').text(@model.proc.pool2.lines)

                @$('#jsCpuVsCpuGameOver')
                .css
                        opacity: 0
                        scale: 0
                .show()
                .transition
                        opacity: 1
                        scale: 1
                        , VIEW_ANIMATE_TIME

            @listenTo @model.proc.pool1, 'gameover', @model.proc.onGameOver
            @listenTo @model.proc.pool2, 'gameover', @model.proc.onGameOver
            Application.Sound.musicPlay()

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
                #@model.proc.charts.series[0].addPoint(@model.proc.pool1.lines, true, @model.proc.charts.series[0].data.length>limit)

            @model.proc.onNext2 = ->
                @model.proc.pool2.trigger 'gameover' if @model.proc.pool2.attributes.index>limit*2
                #@model.proc.charts.series[1].addPoint(@model.proc.pool2.lines, true, @model.proc.charts.series[1].data.length>limit)

            @listenTo @model.proc.pool1, 'nextShape', @model.proc.onNext1
            @listenTo @model.proc.pool2, 'nextShape', @model.proc.onNext2



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

    init: ->
        @$('#jsSinglePlayGameOver .jsPlayAgain')
            .click ->
                Application.Game.switch(GAME_MODE.SINGLE_PLAYER)

        @$('#jsPlayerVsCpuGameOver .jsPlayAgain')
            .click ->
                Application.Game.switch(GAME_MODE.PLAYER_VS_CPU)

        @$('#jsCpuVsCpuGameOver .jsPlayAgain')
            .click ->
                Application.Game.switch(GAME_MODE.CPU_VS_CPU)

        @$('.jsExitToMenu, #jsControlMenu')
            .click ->
                Application.Game.switch(GAME_MODE.LOBBY)

        disabled = 'button-disabled'

        if window.localStorage.getItem('jsControlSound') is 'true'
            @$('#jsControlSound').addClass(disabled)
            Application.Sound.switchAudio(1, false)

        if window.localStorage.getItem('jsControlMusic') is 'true'
            @$('#jsControlMusic').addClass(disabled)
            Application.Sound.switchAudio(0, false)

        @$('#jsControlSound, #jsControlMusic').click ->
            $this = $(this)
            $this.toggleClass disabled
            turnOff = $this.is ".#{disabled}"
            id = $this.attr('id')
            Application.Sound.switchAudio(id is 'jsControlSound', !turnOff)
            window.localStorage.setItem(id, turnOff)