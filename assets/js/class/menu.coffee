# MAIN LOBBY MODEL
class Application.Model.Lobby extends Backbone.Model


# MAIN LOBBY VIEW
class Application.View.Lobby extends Backbone.View
    node: '#jsLobby'
    mainMenu: null

    modelHandler:
        change: ->

    init: ->
        @mainMenu = Application.createMenu 'Main menu',
            'Single player': ->
                Application.Game.switch(GAME_MODE.SINGLE_PLAYER)

            'Player vs CPU': ->
                Application.Game.switch(GAME_MODE.PLAYER_VS_CPU)

            'CPU vs CPU': ->
                Application.Game.switch(GAME_MODE.CPU_VS_CPU)

            , @
        @$el.append @mainMenu.view.$el

# MENU COLLECTION
class Application.Collection.Menu extends Backbone.Collection
    model: Application.Model.MenuItem
    setTitle: (title)->
        @title = title
        @trigger('title', title)

    title: ''

# MENU COLLECTION VIEW
class Application.View.Menu extends Backbone.View
    template: 'tplMenu'
    $title: null
    collectionHandler:
        Menu:
            title: (title)-> @$title.text title
            add: (model)->
                menuItemView = new Application.View.MenuItem
                    model: model
                @$('.jsMenuItems').append(menuItemView.$el)

    render: ->
        @$el = $ @.node
            title: @collection.Menu.title

    init: ->
        @render()
        $title = @$('.jsMenuTitle')

# MENU ITEM
class Application.Model.MenuItem extends Backbone.Model
    triggerHandler: null
    context: this
    defaults:
        title: 'MenuItem'
        active: false
        value: null
        values: null

    init: (params)->
        @triggerHandler = params.triggerHandler if params.triggerHandler?
        @context = params.context if params.context?

# MENU ITEM VIEW
class Application.View.MenuItem extends Backbone.View
    template: 'tplMenuItem'
    modelHandler:{}
    events:
        'click': ->
            Application.Sound = new Application.Class.Sound() if not Application.Sound
            #disabled = 'button-disabled'

#            if window.localStorage.getItem('jsControlSound') is 'true'
#              @$('#jsControlSound').addClass(disabled)
#              Application.Sound.switchAudio(1, false)
#
#            if window.localStorage.getItem('jsControlMusic') is 'true'
#              @$('#jsControlMusic').addClass(disabled)
#              Application.Sound.switchAudio(0, false)

            @model.triggerHandler.apply @model.context
