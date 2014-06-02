# Particle system
class Application.Sprite
    params:
        x: 0
        y: 0
        w: 0
        h: 0

        delay: 100
        repeat: false
        src: ''

        frames: []

    $el: null
    pointer: 0
    len: 0
    #anim: ($spark, css)

    play: (x,y)=>
        css =
            backgroundPosition: "-#{@params.frames[@pointer][0]}px -#{@params.frames[@pointer][1]}px"
            opacity: 1

        css.left = "#{x}px" if x?
        css.top = "#{y}px" if y?

        @$el.css css

        if ++@pointer>=@len
            @pointer = 0
            if not @params.repeat
                @$el.css
                    opacity: 0
                return

        _.delay @play, @params.delay, x, y

    constructor: (params)->
        _(@params).extend(params)

        @len = @params.frames.length
        @$el = $(document.createElement('DIV')).addClass('sprite').css
            backgroundImage: "url(#{@params.src})"
            left: @params.x
            top: @params.y
            height: @params.h
            width: @params.w

