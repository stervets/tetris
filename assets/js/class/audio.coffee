class Application.Model.Audio extends Backbone.Model


class Application.Collection.Audio extends Backbone.Collection
    buffer: [0...AUDIO_BUFFER_SIZE]
    model: Application.Model.Audio

    init: ->
