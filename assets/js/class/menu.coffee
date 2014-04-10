# MAIN LOBBY MODEL
class Application.Model.Lobby extends Backbone.Model


# MAIN LOBBY VIEW
class Application.View.Lobby extends Backbone.View
    node: '#jsMenu'
    modelHandler:
        change: ->

    init: ->

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
        Menu:{}

    init: ->
        $title = @$('.jsMenuTitle')

# MENU ITEM
class Application.Model.MenuItem extends Backbone.Model
    object: null
    defaults:
        title: 'MenuItem'
        active: false
        value: null
        values: null
        trigger: null
    init: ()->
        _dump arguments

# MENU ITEM VIEW
class Application.View.MenuItem extends Backbone.View
    template: 'tplMenuItem'
    modelHandler:{}
