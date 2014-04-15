class Application.Model.Sound extends Backbone.Model


class Application.Collection.Sound extends Backbone.Collection
    buffer: [0...AUDIO_BUFFER_SIZE]
    index: 0
    model: Application.Model.Sound
    music: null

    play: (file)->
        sound = @buffer[@index]
        sound.src = file
        sound.load()
        sound.play()
        @index = 0 if ++@index>=AUDIO_BUFFER_SIZE

    musicPlay: ->
        @music.load()
        @music.play()

    musicStop: ->
        @music.pause()


    initialize: ->
        return if !window.Audio?
        @music = new Audio(RES.AUDIO.GAME_MUSIC)
        @music.volume = 0.7
        @music.load()
        @music.addEventListener('ended', ->
                                 this.currentTime = 0;
                                 this.play();
                        , false)

        for key, val of RES.AUDIO
            sound = new Audio(val)
            sound.load();

        for index in @buffer
            @buffer[index] = new Audio()
            @buffer[index].pause()
            @buffer[index].startTime = 0
