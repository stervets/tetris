# Particle system
class Application.Particle
    params:
        x: 0
        y: 0
        distanceX: 200 # spark fly distance
        distanceY: 30 # spark fly distance

        lifetime: 300 # spark animation time
        particlesMax: 5 # Max particles
        stackSize: 120 # Max particles

    #color: ['#f0f0f0', '#88db1f', '#f0c729', '#60d890', '#3b9adf', '#e35242', '#9f5cab']
    color: ['#FFFFFF', '#98eb2f', '#ffd739', '#70e8a0', '#4baaef', '#f36252', '#af6cbb']

    particleHtml: $('#tplParticle').html()
    sparkHtml: $('#tplSpark').html()

    #$parent: $('body')
    $el: null

    play: false
    stepTime: 10
    $particle: []

    pointer: 0

    #anim: ($spark, css)

    launch: (x, y, color, x2)->
        #for i in [0...1]

            $p = @$particle[@pointer]
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
                            #top: y+POOL.CELL_SIZE/2
                            #left: x+rand(-params.distanceX,params.distanceX)
                            left: (if x2? then x2 else x)+params.x
                            #opacity: 0.5
                            scale: 0
                            rotate: "#{rand(-180, 180)}deg"
                            color: 'white'
                            transition: "all #{params.lifetime}ms ease"
                            #transitionDuration: "#{params.lifetime}ms"
                        null
                    , @stepTime, $p, @params, x, y, x2

            @pointer = 0 if ++@pointer >= @$particle.length

    constructor: (params)->
        _(@params).extend(params)
        @$el = $(@particleHtml)
        @$particle = []
        for i in [1..@params.stackSize]
            $spark = $(@sparkHtml).css(transitionDuration: "#{@params.lifetime}ms")
            @$particle.push $spark
            @$el.append $spark
