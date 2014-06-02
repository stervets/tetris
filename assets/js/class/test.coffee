class Proto
    params: {

    }

    getData: -> JSON.stringify(@params)

    setData: (name, value)->
        if typeof name is 'object' then $.extend(@params, params) else @params[name] = value

    @mydata: ->
        console.log 111

    constructor: (params)->
        $.extend(@params, params)
        console.log('test')

class CustomCharts extends Proto
    constructor: (params)->
        super(params);
        console.log 'test2'