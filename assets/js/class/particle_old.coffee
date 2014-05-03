# Particle system
class Application.Particle
    params:
        distance: 150 # spark fly distance
        lifetime: 300 # spark animation time
        particlesMax: 10 # Max particles
        stackSize: 100 # Max particles

    particleHtml: $('#tplParticle').html()
    sparkHtml: $('#tplSpark').html()

    #$parent: $('body')
    $el: null

    play: false
    stepTime: 10
    $particle: []

    pointer: 0

    #anim: ($spark, css)

    launch: (x, y)->
        for i in [0...rand(0, @particlesMax)]
            $p = @$particle[@pointer]
            $p
            .css
                    top: y
                    left: x
                    opacity: 1
                    rotate: "#{rand(-180, 180)}deg"
                    scale: rand(50,150)/100
                    color: "rgb(#{rand(100, 255)},#{rand(100, 255)},#{rand(100, 255)})"

            @$el.append $p

            _.delay ($p, params, x, y)->
                        $p.css
                            top: y+rand(-params.distance,params.distance)
                            left: x+rand(-params.distance,params.distance)
                            opacity: 0
                            rotate: "#{rand(-180, 180)}deg"
                        null
                    , @stepTime, $p, @params, x, y
            @pointer = 0 if ++@pointer >= @$particle.length

    constructor: (params)->
        _(@params).extend(params)
        @$el = $(@particleHtml)
        @$particle = []
        @$particle.push $(@sparkHtml).css(transitionDuration: "#{@params.lifetime}ms") for i in [1..@params.stackSize]

