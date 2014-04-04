#QUnit.config.autostart = true;

### Application skeleton ###
@Application =
    Class:
        Model: {}
        Collection: {}
        View: {}
    Model: {}
    Collection: {}
    View: {},
    Templates: {}

    _startFunctions: []

    ### start module ###
    onStart: (func)->
        isFunction = _.isFunction(func)
        Application._startFunctions.push(func) if isFunction
        isFunction

    ### load templates ###
    loadTemplates: ->
        templates = $("script[type='text/template']")
        for template in templates
            Application.Templates[$(template).attr 'id'] = Handlebars.compile($(template).html())
        templates.length

    ### Start app ###
    Start: ->
        if TEST_MODE
            $('body').append(Application.Templates.tplTest())
            Application._startTest = _.extend(Application._startTest, Application.startTest) if _.isObject(Application.startTest)
            Application._runTest = _.extend(Application._runTest, Application.runTest) if _.isObject(Application.runTest)

            _(Application._startTest).each (func, name)->
                test name, func

            Application.Test('runTest1', @, 22)

        _(Application._startFunctions).each (func)->
            do func

    genId : (prefix='Object')->
        "#{prefix}-#{rand(0xFFFFFF)}-#{rand(0xFFFFFF)}-#{rand(0xFFFFFF)}-#{rand(0xFFFFFF)}"

    Test: (name, thisPointer, attr...)->
        if TEST_MODE and runTest = Application._runTest[name]
            thisPointer = @ if not thisPointer?
            test(name, _.bind(runTest, thisPointer, attr...))


Application._startTest = {}

Application._runTest = {}


### Ginger options ###
_(Backbone.Ginger.options).extend
    templateParentObject: Application.Templates
    modelImportParentObject: Application.Class.Model
    collectionImportParentObject: Application.Class.Collection
    collectionImportVariable: '#'

### Autolink handler ###
Backbone.Model::initialize = (attr...)->
    @on event, handle for event, handle of @handler when _.isFunction(handle) if _.isObject(@handler)
    @init(attr...) if _.isFunction(@init)

### Main init ###
$ ->
    appStart = ->
        Application.loadTemplates()
        Application.Start()

    window.localStorage.clear() if document.URL.indexOf('?reset') >= 0

    includes = 0
    $('include').each ->
        node = $(@)
        if node.attr 'src'
            includes++
            $.get node.attr('src'), (res)->
                node[0].outerHTML = res
                if --includes <= 0
                    appStart()

    appStart() if not includes