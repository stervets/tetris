class Application.Class.Sound
    musicFiles:
        game: RES.AUDIO.GAME_MUSIC
        menu: RES.AUDIO.MENU_MUSIC
        win: RES.AUDIO.WIN
        fail: RES.AUDIO.FAIL

    muteMusic: false
    muteSound: false

    audio: null

    play: ()->

    musicPlay: ->

    musicStop: ->

    switchAudio: (type, value)->
        if type
            @muteSound = value
        else
            @muteMusic = value

    constructor: ->
        @audio = new (window.AudioContext || window.webkitAudioContext)()


###
class Application.Model.Sound extends Backbone.Model



class Application.Collection.Sound extends Backbone.Collection
    buffer: [0...AUDIO_BUFFER_SIZE]
    index: 0
    model: Application.Model.Sound
    music: null
    soundEnabled: true
    musicEnabled: true
    musicPaused: false

    play: (file)->
        if @soundEnabled
            sound = @buffer[@index]
            sound.src = file
            sound.load()
            sound.volume = 1
            sound.play()
            @index = 0 if ++@index>=AUDIO_BUFFER_SIZE

    musicPlay: ->
        if @musicEnabled
            @musicPaused = false
            @music.load()
            @music.play()

    musicStop: ->
        @music.pause()
        @musicPaused = true

    switchAudio: (type, value)->
        if type
            @soundEnabled = value
        else
            @musicEnabled = value
            if value
                @music.play() if not @musicPaused
            else
                @music.pause()

    initialize: ->
        return if !window.Audio?
        @music = new Audio(RES.AUDIO.GAME_MUSIC)
        @music.volume = 1
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
###
