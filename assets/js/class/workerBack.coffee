###
 * worker.postMessage({
 *  method : {methodName}
 *  vars : {vars}
 *  callback: {callbackFunction}
 * })


    function rand(min, max) {
    if(max == undefined) {
        max = min;
        min = 0;
    }
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

###
importScripts '/assets/js/lib/underscore-min.js', '/assets/js/class/const.js'

rand = (min,max)->
    [min, max] = [0, min] if not max?
    Math.floor(Math.random() * (max - min + 1)) + min

worker = self

_dump = (vars...)->
    worker.postMessage
        callback: 'dump'
        vars: vars

_mat = (matrix, id)->
    worker.postMessage
        callback: 'mat'
        vars:
            matrix: matrix
            id: id

matrixCopy = (source)->
    matrix = []
    matrix.push(line[..]) for line in source
    matrix


collide = (matrix, shape, posX, posY)->
    width = matrix[0].length
    height = matrix.length

    for line, i in shape
        y = i+posY
        for val, j in line
            x = j+posX
            return true if val and (y>=height or x<0 or x>=width or (y>=0 and matrix[y][x]))

    return false

putShape = (matrix, shape, posX, posY)->
    width = matrix[0].length
    height = matrix.length
    overflow = false

    for line, i in shape
        y = i+posY
        continue if y >= height
        if y < 0
            overflow = true if not overflow and isInLine(line)
            continue

        for val, j in line
            x = j+posX
            matrix[y][x] = val if val and x >= 0 and x < width

    return {
        matrix: matrix
        overflow: overflow
    }

isInLine = (line)->
    for i in line
        return true if i
    return false

isFullLine = (line)->
    return false for i in line when not i
    return true


isInVert = (source, col)->
    for line in source
        return true if line[col]
    return false


trim = (source)->
    result =
        minX: -1
        maxX: 0
        minY: -1
        maxY: 0
        matrix: []
        fullLine: -1

    for i in [0...source.length]
        if isInVert(source, i)
            result.maxX = i
            result.minX = i if result.minX < 0
        else
            break if result.minX>0

    for line, i in source
        if isInLine(line)
            trimLine = line[result.minX..result.maxX]
            result.maxY = i
            result.minY = i if result.minY < 0
            result.fullLine = result.matrix.length if result.fullLine<0 and isFullLine(trimLine)
            result.matrix.push(trimLine)

    result.minX = 0 if result.minX<0
    result.minY = 0 if result.minY<0
    result.shiftX = source.length - (result.maxX - result.minX) - 1
    result.shiftY = source.length - (result.maxY - result.minY) - 1
    result.width = result.matrix[0].length
    result.height = result.matrix.length
    result.fullLine = result.height-1 if result.fullLine<0

    result

getDrop = (matrix, shape, x, y)->
    y++ until collide matrix, shape, x, y
    y-1

getFullLines = (matrix, shape, posX, posY)->
    width = matrix[0].length
    height = shape.length
    lines = []
    for y in [0...height]
        yy = y + posY
        continue if yy<0 or yy>=matrix.length
        full = true
        for x in [0...width]
            if not matrix[yy][x] and not shape[y][x-posX]
                full = false
                break
        lines.push yy if full
    lines

getPercent = (part, all)-> Math.round((part*100)/all)

getFillness = (matrix, shape, posX, posY, fullLine)->
    shapeWidth = shape[0].length
    shapeHeight = shape.length
    matrixWidth = matrix[0].length
    matrixHeight = matrix.length

    all = 0
    filled = 0
    holes = 0

    for y in [-1..shapeHeight] # Влияет на holes !!!
        yy = y + posY
        continue if not (0<=yy<matrixHeight)
        inShapeV = 0<=y<shapeHeight
        for x in [-1..shapeWidth]
            xx = x + posX
            continue if not (0<=xx<matrixWidth)
            inShapeH = 0<=x<shapeWidth
            all++
            if matrix[yy][xx] or (inShapeV and inShapeH and shape[y][x])
                filled++
            else
                holes++ if inShapeH and y>=fullLine

    return {
        percent: getPercent(filled, all)
        holes: 100-getPercent(holes, all)
    }


scoreFormula = [
    # Склонен строить башни
    (height, fillness, holes, lines)-> height+fillness+holes*4+lines
    # Сбалансирован, но не любит линии.
    (height, fillness, holes, lines)-> height*2+fillness+holes*4+lines
    # Слишком любит линии - looser
    (height, fillness, holes, lines)-> height*2+fillness+holes*4+lines*2
    # любит линии!!!
    (height, fillness, holes, lines)-> height*2+fillness*2+holes*2+lines

    # II лига
    (height, fillness, holes, lines)-> (height+1)*(holes+1)+(fillness+1)*(lines+1) #4


    #увеличить fillness
    (height, fillness, holes, lines)-> ((height+1)*(holes+1))+(fillness*2+1)*(lines+1) #5

    (height, fillness, holes, lines)-> (height+1)/((100-holes+1)) + (lines+1) * 10 + fillness #6 RULES

    # очков меньше, но стабилен жеж. Выиграл у восьмого, набрав 3050
    (height, fillness, holes, lines)-> (height+1)/((100-holes+1)) + (lines+1) * 2 + (fillness+1)*2  #7 nu leader. Абсолютно круче всех.

    #мегакрут. Проиграл седьмому на 3485 очках
    (height, fillness, holes, lines)-> (height+1)/((100-holes+1)) + (lines+1) + (fillness)*2  #8 слабее 7ки
    #(height, fillness, holes, lines)-> height/((100-holes+1)/2) + lines * 10 + fillness

    (height, fillness, holes, lines)-> (fillness)/((100-holes+1)) + (lines) + height #9

    (height, fillness, holes, lines)-> ((height+1))/((100-holes+1)) + (lines+1) + (fillness) #10 наследник восьмого

    (height, fillness, holes, lines)-> (((height+1))/((100-holes+1)) + (lines+1) + (fillness))*(if height>50 then 10 else 1) #11 наследник восьмого


    (height, fillness, holes, lines)-> ((height+1)/((100-holes+1)) + (lines+1) + (fillness)*2)*height  #12 На синтетике намного лучше чем 8

    # очков меньше, но стабилен жеж. Выиграл у восьмого, набрав 3050
    (height, fillness, holes, lines)-> (fillness+1)/((100-holes+1)) + (lines+1)+(height+1)*2  #13 играет опаснее 7ки, но эффективнее по очкам

    (height, fillness, holes, lines)-> ((height+1))/((100-holes+1)) + (lines+1) * 2 + (fillness+1)*3  #14 уделал семерку и по очкам тоже. Единственный конкурент семерке.
    (height, fillness, holes, lines)-> ((height+1)*2)/((100-holes+1)) + (lines+1) * 2 + (fillness+1)*3  #15 проигрывает семерке, но мне нравится его стиль.

    #(height, fillness, holes, lines)-> height/holes + lines * 10 + fillness # new favorite! 6
]

spells = [
    (matrix, value)->
        matrix[index-value] = line[..] for line, index in matrix when index>value-1
        len = matrix[0].length-1
        empty = rand(0, len)
        lines = []

        for y in [matrix.length-value...matrix.length]
            line = []
            for x in [0..len]
                line.push if x is empty then 0 else SHAPE_SPECIAL+SPELL.GROUND
            lines.push(matrix[y] = line)

        {
            matrix: matrix
            spell: lines
        }

]

getScore = (matrix, shape, posX, posY, formula)->
    if not formula?
        console.log 'Warning getScore formula is not set. Setted to 0'
        formula = 0

    trimShape = trim(shape)
    x = posX+trimShape.minX
    y = posY+trimShape.minY
    matrixHeight = matrix.length

    fill = getFillness(matrix, trimShape.matrix, x, y, trimShape.fullLine)
    score =
        height: getPercent(y, matrixHeight)
    #    width: getPercent(Math.abs(matrixWidth/2-posX), matrixWidth/2)+1
        fillness: fill.percent
        holes: fill.holes
        lines: getPercent(getFullLines(matrix, shape, posX, posY).length, 4)

    #getPercent = (part, all)-> Math.round((part*100)/all)

    #console.log score.lines
    score.score = Math.round(scoreFormula[formula](score.height, score.fillness, score.holes, score.lines))
    score


getPath = (x1, x2, angle1, angle2)->
    result = []
    for angle in [angle1...angle2]
        result.push if angle1<angle2 then 'rotateRight' else 'rotateLeft'

    for x in [x1...x2]
        result.push if x1<x2 then 'moveRight' else 'moveLeft'
    result

triggers =
    checkMoveDown: (vars)->
        worker.postMessage
            callback: 'checkMoveDown',
            vars:
                collided: collide vars.matrix, vars.shape, vars.x, vars.y + 1
                id: vars.id
                #key: vars.key

    checkMoveLeft: (vars)->
        worker.postMessage
            callback: 'checkMoveLeft',
            vars:
                collided: collide vars.matrix, vars.shape, vars.x-1, vars.y
                id: vars.id

    checkMoveRight: (vars)->
        worker.postMessage
            callback: 'checkMoveRight',
            vars:
                collided: collide vars.matrix, vars.shape, vars.x+1, vars.y
                id: vars.id

    checkRotate: (vars, callback)->
        offsetX = 0
        if collided = collide vars.matrix, vars.shape, vars.x, vars.y
            halfSize = Math.floor vars.shape[0].length/2
            for offset in [1..halfSize]
                if not collide vars.matrix, vars.shape, vars.x+offset, vars.y
                    collided = false
                    offsetX = offset
                    break
                if not collide vars.matrix, vars.shape, vars.x-offset, vars.y
                    collided = false
                    offsetX = -offset
                    break

        worker.postMessage
            callback: callback,
            vars:
                collided: collided
                x: vars.x+offsetX
                y: vars.y
                id: vars.id

    checkRotateLeft: (vars)->
        triggers.checkRotate vars, 'checkRotateLeft'

    checkRotateRight: (vars)->
        triggers.checkRotate vars, 'checkRotateRight'


    checkDrop: (vars, setDrop=false)->
        #vars.y++ until collide vars.matrix, vars.shape, vars.x, vars.y
        worker.postMessage
            callback: 'checkDrop',
            vars:
                drop: getDrop vars.matrix, vars.shape, vars.x, vars.y
                setDrop: setDrop
                id: vars.id

    setDrop: (vars)->
        triggers['checkDrop'](vars, true)

    putShape: (vars)->
        worker.postMessage
            callback: 'putShape',
            vars:
                result: putShape matrixCopy(vars.matrix), vars.shape, vars.x, vars.y
                id: vars.id

    process: (vars)->
        matrix = []
        emptyLine = (0 for _dummy in [0...vars.matrix[0].length])
        lines = []

        for line, y in vars.matrix
            if isFullLine(line)
                matrix.unshift(emptyLine)
                lines.push y
            else
                matrix.push(line)

        worker.postMessage
            callback: 'process',
            vars:
                matrix: matrix
                lines: lines
                id: vars.id

    findPlace: (vars)->
        #formula = if vars.formula? and scoreFormula[vars.formula]? then vars.formula else 0
        vars.smart = 100 if not vars.smart?
        formula = vars.formula
        matrix = vars.matrix
        matrixWidth = matrix[0].length
        shapeWidth = vars.shape[0].length

        x = vars.x
        y = -vars.shape.length+1

        scores = {}
        max = 0

        maxAngle = SHAPE_ANGLES[vars.shapeIndex] || 4

        for xx in [-shapeWidth...matrixWidth]
            for angle in [0...maxAngle]
                shape = vars.shape[angle]
                continue if (droppedY = getDrop(matrix, shape, xx, y))<=0
                score = getScore(matrix,shape,xx,droppedY,formula).score
                if not scores[score]?
                    scores[score] =
                        score: score
                        x: xx
                        y: droppedY
                        angle: angle

                max = score if max < score


        #scores.push(max.key)
        keys = Object.keys(scores)
        len = keys.length
        rnd = -1
        if len>1
            rnd = rand(1, 100)
            key = keys[len-(if rnd<vars.smart then 1 else 2)]

        else
            key = keys[0]

        #_dump rnd, (if rnd<vars.smart then 'win' else 'fail'), (keys[len-(if rnd<vars.smart then 1 else 2)]+' of '+keys[len-1])
        #rnd = rand(Math.round(keys.length*vars.smart), keys.length)-1
        #key = keys[rnd]

        #break for key in [Math.round(max*vars.smart)..max] when scores[key]?
        #_dump key, scores
        #_dump 'MIN: '+Math.round(keys.length*vars.smart-1)+' of '+(keys.length-1), 'Selected: '+rnd, keys
        result = if scores[key]
                    score = scores[key]
                    score.path = getPath(x, score.x, vars.angle, score.angle)
                    score
                else
                    path:[]
                    score: -1
                    x:x
                    y:-10
                    angle: vars.angle

        result.path = result.path.concat('drop')
        #_dump result
        worker.postMessage
            callback: 'findPlace',
            vars:
                result: result
                id: vars.id

    getScore: (vars)->
        droppedY = getDrop(vars.matrix, vars.shape, vars.x, vars.y)
        res = getScore(vars.matrix,vars.shape,vars.x,droppedY)
        worker.postMessage
            callback: 'getScore',
            vars:
                result: res
                id: vars.id

    postProcess: (vars)->
        result =
            matrix: vars.matrix
            spell: {}

        for spell, value of vars.spell when value
            #console.log spell+' '+value
            res = spells[spell](result.matrix, value)
            result.matrix = res.matrix
            result.spell[spell] = res.spell

        worker.postMessage
            callback: 'postProcess',
            vars:
                id: vars.id
                result: result

worker.addEventListener 'message',
    (e)->
        data = e.data;
        triggers[data.trigger](data.vars, data.callback) if triggers[data.trigger]?
    , false
