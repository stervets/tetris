
spellCast = (lines, score, combo)->
    pool = Application.Pool.at(if Application.Pool.at(0).id is @id then 1 else 0)
    if value = lines.length+combo-2
        spellValue = @getSpell(SPELL.GROUND)-value
        @setSpell SPELL.GROUND, if spellValue>0 then spellValue else 0
        pool.setSpell SPELL.GROUND, pool.getSpell()+Math.abs(spellValue)


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

    switch: (mode, param)-> if @attributes.mode is mode then @trigger('change:mode', @, mode, param) else @set('mode', mode, param)

    mode: [
        #loading
        ->
        #Lobby
        ->
            @gameReset()

        # Single player
        (isCPU)->
            @gameReset()

            if isCPU is true
              @proc.controller = new Application.Model.Controller.AI
                  formula: CPU[0].FORMULA
                  smart: CPU[0].SMART
                  actionDelay: 150
            else
              @proc.controller = new Application.Model.Controller.User()

            Application.Controller.add(@proc.controller)
            @proc.pool = new Application.Model.Pool
                controller: @proc.controller.id
            Application.Pool.add(@proc.pool)
            @proc.controller.start()

        #PLayer vs CPU
        ->
            @gameReset()
            @proc.controller1 = new Application.Model.Controller.User()

            Application.Controller.add(@proc.controller1)
            @proc.pool1 = new Application.Model.Pool
                controller: @proc.controller1.id
            Application.Pool.add(@proc.pool1)
            @proc.controller1.start()

            @proc.controller2 = new Application.Model.Controller.AI
                formula: CPU[0].FORMULA
                smart: CPU[0].SMART - 20
            Application.Controller.add(@proc.controller2)
            @proc.pool2 = new Application.Model.Pool
                controller: @proc.controller2.id
            Application.Pool.add(@proc.pool2)
            @proc.controller2.start()

            @proc.pool1.on 'lines', spellCast, @proc.pool1
            @proc.pool2.on 'lines', spellCast, @proc.pool2

        #CPU vs CPU
        ->
            actionDelay = 150
            @gameReset()
            @proc.controller1 = new Application.Model.Controller.AI
                formula: CPU[0].FORMULA
                smart: CPU[0].SMART
                actionDelay: actionDelay
            Application.Controller.add(@proc.controller1)
            @proc.pool1 = new Application.Model.Pool
                controller: @proc.controller1.id
            Application.Pool.add(@proc.pool1)
            @proc.controller1.start()

            @proc.controller2 = new Application.Model.Controller.AI
                formula: CPU[1].FORMULA
                smart: CPU[1].SMART
                actionDelay: actionDelay
            Application.Controller.add(@proc.controller2)
            @proc.pool2 = new Application.Model.Pool
                controller: @proc.controller2.id
            Application.Pool.add(@proc.pool2)
            @proc.controller2.start()

            @proc.pool1.on 'lines', spellCast, @proc.pool1
            @proc.pool2.on 'lines', spellCast, @proc.pool2

    ]

    handler:
        'change:mode': (model, mode, param)-> @mode[mode].call(@, param) if @mode[mode]?

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
        #Loading
        ->
        #Lobby
        ->
            #Application.switchView('Lobby')
        # Single player
        (isCPU)->
            @model.proc.view = new Application.View.Pool
                x: 900/2 - 450/2
                y: 50
                model: @model.proc.pool

            @$('#jsSinglePlay').html(@model.proc.view.$el)

            @model.proc.onGameOver = =>
                Application.Sound.musicStop()
                @$('#jsSinglePlayGameOver .jsScore').text(@model.proc.pool.score)
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

                if @model.proc.pool1.score == @model.proc.pool2.score
                    @$('.jsGameOverDraw').show()
                else
                    if @model.proc.pool1.score>=@model.proc.pool2.score
                        @$('.jsGameOverWin').show()
                    else
                        @$('.jsGameOverLoose').show()

                @$('#jsPlayerVsCpuGameOver .jsScore').text(@model.proc.pool1.score)
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

                if @model.proc.pool1.score == @model.proc.pool2.score
                    @$('.jsGameOverDraw').show()
                else
                    if @model.proc.pool1.score>=@model.proc.pool2.score
                        @$('.jsGameOverCpu1').show()
                    else
                        @$('.jsGameOverCpu2').show()

                @$('#jsCpuVsCpuGameOver .jsScoreCpu1').text(@model.proc.pool1.score)
                @$('#jsCpuVsCpuGameOver .jsScoreCpu2').text(@model.proc.pool2.score)

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
    ]

    modelHandler:
        change: ->

        'change:mode': (model, mode, param)->
            if @mode[mode]?
                delay = if @$('.game-inner:visible').length then VIEW_ANIMATE_TIME else 0
            $gameInner = @$('.game-inner')
            $gameInner.transition
                opacity: 0
                , _.once =>
                    @$('.game-inner').hide()
                    @mode[mode].call @, param

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

        $('body').keyup (e)->
          Application.Game.switch(GAME_MODE.LOBBY) if e.keyCode is 27

        disabled = 'button-disabled'

        @$('#jsControlSound, #jsControlMusic').click ->
            console.log "here"
            $this = $(this)
            $this.toggleClass disabled
            turnOff = $this.is ".#{disabled}"
            id = $this.attr('id')
            Application.Sound.switchAudio(id is 'jsControlSound', !turnOff)
            window.localStorage.setItem(id, turnOff)



        $(window)
            .blur ->
                    Application.Pool.each (pool)->
                        pool.trigger 'action', 'stop'
            .focus ->
                    Application.Pool.each (pool)->
                        pool.trigger 'action', 'start'
