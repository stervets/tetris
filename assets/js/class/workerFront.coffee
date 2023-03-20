Application.workerCallback =
    dump: (vars)->
        _dump(vars...)
        #console.log vars...

    mat: (vars)->
        _mat(vars.matrix, vars.id)


    checkMoveDown: (vars)->
        if (pool = Application.Pool.get(vars.id))# and vars.key==pool.shape.key
            if vars.collided
                pool.trigger 'action', 'putShape'
            else
                pool.trigger 'action', 'doMoveDown'

    checkMoveLeft: (vars)->
        if pool = Application.Pool.get(vars.id)
            pool.trigger 'action', 'doMoveLeft' if !vars.collided

    checkMoveRight: (vars)->
        if pool = Application.Pool.get(vars.id)
            pool.trigger 'action', 'doMoveRight' if !vars.collided

    checkRotateLeft: (vars)->
        if pool = Application.Pool.get(vars.id)
            if !vars.collided
                pool.setShapeXY vars.x, vars.y
                pool.trigger 'action', 'doRotateLeft'

    checkRotateRight: (vars)->
        if pool = Application.Pool.get(vars.id)
            if !vars.collided
                pool.setShapeXY vars.x, vars.y
                pool.trigger 'action', 'doRotateRight'

    checkDrop: (vars)->
        if pool = Application.Pool.get(vars.id)
            pool.shape.set('drop', vars.drop)
            if vars.setDrop
                pool.shape.set('y', vars.drop)
                pool.trigger 'action', 'putShape'

    putShape: (vars)->

        if pool = Application.Pool.get(vars.id)
            pool.attributes.cells = vars.result.matrix
            pool.trigger 'action', if vars.result.overflow then 'overflow' else 'onPutShape'

    process: (vars)->
        if pool = Application.Pool.get(vars.id)
            pool.attributes.cells = vars.matrix
            pool.trigger 'action', 'postProcess', vars.lines
        ###
        if pool = Application.Pool.get(vars.id)
            pool.attributes.cells = vars.matrix
            if vars.lines.length
                pool.score+=Math.floor(vars.lines.length*vars.lines.length)*(++pool.combo)
                pool.trigger 'action', 'lines', [vars.lines, pool.score, pool.combo]
            else
                pool.combo = 0

            pool.trigger 'action', 'nextShape'
            pool.locked = false
        ###
    postProcess: (vars)->
        if pool = Application.Pool.get(vars.id)
            pool.attributes.cells = vars.result.matrix
            pool.trigger 'spell', index, spell for index, spell of vars.result.spell
            pool.spell = {}
            pool.trigger 'action', 'nextShape'
            pool.locked = false

    findPlace: (vars)->
        if controller = Application.Controller.get(vars.id)
            controller.trigger 'setPath', vars.result

    getScore: (vars)->


Application.worker = new Worker('/assets/js/class/workerBack.js')
Application.worker.addEventListener 'message',
                                    (e)->
                                        Application.workerCallback[e.data.callback](e.data.vars, e.data.callback) if Application.workerCallback[e.data.callback]?
                                    , false
