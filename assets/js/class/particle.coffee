# Particle system
class Application.Particle
    params:
        distanceX: 200 # spark fly distance
        distanceY: 30 # spark fly distance

        lifetime: 300 # spark animation time
        particlesMax: 5 # Max particles
        stackSize: 120 # Max particles

    particleHtml: $('#tplParticle').html()
    sparkHtml: $('#tplSpark').html()

    #$parent: $('body')
    $el: null

    play: false
    stepTime: 10
    $particle: []

    pointer: 0

    #anim: ($spark, css)

    launch: (x, y, color)->
        #for i in [0...1]
            $p = @$particle[@pointer]
            $p
            .css
                    top: y
                    left: x
                    opacity: 1
                    #rotate: "#{rand(-180, 180)}deg"
                    scale: rand(50,150)/100
                    color: color
                    transition: 'none'


            #@$el.append $p

            _.delay ($p, params, x, y)->
                        $p.css
                            top: y+rand(-params.distanceY,params.distanceY)
                            left: x+rand(-params.distanceX,params.distanceX)
                            opacity: 0
                            #rotate: "#{rand(-180, 180)}deg"
                            color: '#FFFFFF'
                            transition: "all #{params.lifetime}ms ease"
                            #transitionDuration: "#{params.lifetime}ms"
                        null
                    , @stepTime, $p, @params, x, y

            @pointer = 0 if ++@pointer >= @$particle.length

    constructor: (params)->
        _(@params).extend(params)
        @$el = $(@particleHtml)
        @$particle = []
        for i in [1..@params.stackSize]
            $spark = $(@sparkHtml).css(transitionDuration: "#{@params.lifetime}ms")
            @$particle.push $spark
            @$el.append $spark
