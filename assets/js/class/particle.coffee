# Particle system
class Application.Particle
    params:
        x: 0
        y: 0
        distanceX: 0 # spark fly distance
        distanceY: 30 # spark fly distance

        lifetime: 300 # spark animation time
        particlesMax: 5 # Max particles
        particleNum: 120 # Max particles

        messageNum: 5 # Max messages

    #color: ['#f0f0f0', '#88db1f', '#f0c729', '#60d890', '#3b9adf', '#e35242', '#9f5cab']
    color: ['#FFFFFF', '#98eb2f', '#ffd739', '#70e8a0', '#4baaef', '#f36252', '#af6cbb']

    particleHtml: $('#tplParticle').html()
    messageHtml: $('#tplMessage').html()
    sparkHtml: $('#tplSpark').html()

    #$parent: $('body')
    $el: null

    play: false
    stepTime: 10
    $particle: []
    $message: []

    particlePointer: 0
    messagePointer: 0
    #anim: ($spark, css)

    launch: (x, y, color, x2)->
        #for i in [0...1]

            $p = @$particle[@particlePointer]
            #console.log $p.length
            $p
            .css
                    top: y+@params.y
                    left: x+@params.x
                    opacity: 1
                    rotate: "#{rand(-180, 180)}deg"
                    #scale: rand(50,150)/100
                    scale: 2.5
                    color: @color[color]
                    #color: 'white'
                    transition: 'none'


            #@$el.append $p

            _.delay ($p, params, x, y, x2)->
                        $p.css
                            top: y+rand(0,params.distanceY)+params.y
                            left: (if x2? then x2 else x)+params.x
                            scale: 0
                            rotate: "#{rand(-180, 180)}deg"
                            color: 'white'
                            transition: "all #{params.lifetime}ms ease-out"
                            #transitionDuration: "#{params.lifetime}ms"
                        null
                    , @stepTime, $p, @params, x, y, x2

            @particlePointer = 0 if ++@particlePointer >= @$particle.length

    message: (text, y, color=0)->
        $p = @$message[@messagePointer]
        $p
        .text text
        .css
                top: @params.y+y
                left: @params.x
                opacity: 1
                color: @color[color]
                transition: 'none'

        _.delay ($p, params, y)->
                    #ease = if rand(0,1) then 'ease-out' else 'ease-in'
                    #_dump ease
                    $p.css
                        top: params.y-params.distanceY+y
                        opacity: 0
                        transition: "all #{params.lifetime*2}ms ease-out"
                    null
                , @stepTime, $p, @params, y


        @messagePointer = 0 if ++@messagePointer >= @$message.length

    constructor: (params)->
        _(@params).extend(params)
        @$el = $(@particleHtml)
        @$particle = []
        for i in [1..@params.particleNum]
            $spark = $(@sparkHtml)
            @$particle.push $spark
            @$el.append $spark
        @$message = []
        for i in [1..@params.messageNum]
            $message = $(@messageHtml)
            @$message.push $message
            @$el.append $message
