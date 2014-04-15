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
importScripts '/js/lib/underscore-min.js', '/js/class/const.js'

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
        continue if (yy = y + posY)<0 or yy>=matrix.length
        full = true
        for x in [0...width]
            if !matrix[yy][x] and !shape[y][x]
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
        holes: holes
    }


scoreFormula = [
    (height, fillness, holes, lines)-> Math.round((height*2 + fillness)/(holes)) * (lines*2) # 0
    (height, fillness, holes, lines)-> Math.round((height*2 * fillness)/(holes)) * (lines*2)  # 1 (leader)
    (height, fillness, holes, lines)-> Math.round((lines*height*fillness)/holes)  # 1 optimized
    (height, fillness, holes, lines)-> (lines*100 + fillness*50 + height*25)/holes # same! why?
    (height, fillness, holes, lines)-> (lines*100 + height*50 + fillness*25)/holes
    (height, fillness, holes, lines)-> (fillness*100 + height*50 + lines*25)/holes #  same! why?
    (height, fillness, holes, lines)-> height/holes + lines * 10 + fillness # new favorite!

]

getScore = (matrix, shape, posX, posY, formula)->
    trimShape = trim(shape)
    x = posX+trimShape.minX
    y = posY+trimShape.minY
    matrixHeight = matrix.length

    fill = getFillness(matrix, trimShape.matrix, x, y, trimShape.fullLine)
    score =
        height: getPercent(y, matrixHeight)
    #    width: getPercent(Math.abs(matrixWidth/2-posX), matrixWidth/2)+1
        fillness: fill.percent
        holes: fill.holes+1
        lines: getFullLines(matrix, shape, posX, posY).length+1

    score.score = scoreFormula[formula](score.height, score.fillness, score.holes, score.lines)
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
                key: vars.key

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


    checkDrop: (vars)->
        #vars.y++ until collide vars.matrix, vars.shape, vars.x, vars.y
        worker.postMessage
            callback: 'checkDrop',
            vars:
                drop: getDrop vars.matrix, vars.shape, vars.x, vars.y
                id: vars.id

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
        formula = if vars.formula? and scoreFormula[vars.formula]? then vars.formula else 0
        matrix = vars.matrix
        matrixWidth = matrix[0].length
        shapeWidth = vars.shape[0].length

        x = vars.x
        y = -vars.shape.length+1

        scores = []
        max =
            score: 0
            key: 0

        maxAngle = SHAPE_ANGLES[vars.shapeIndex] || 4

        for xx in [-shapeWidth...matrixWidth]
            for angle in [0...maxAngle]
                shape = vars.shape[angle]
                continue if (droppedY = getDrop(matrix, shape, xx, y))<=0
                score = getScore(matrix,shape,xx,droppedY,formula).score
                key = scores.length
                scores.push
                    score: score
                    x: xx
                    y: droppedY
                    angle: angle

                max = {score: scores[key].score, key: key} if max.score < scores[key].score


        scores.push(max.key)

        result = if scores[max.key]
                    score = scores[max.key]
                    score.path = getPath(x, score.x, vars.angle, score.angle)
                    #score.path = score.path.concat(['moveDown','moveDown','moveDown'])
                    score
                else
                    path:[]
                    score: -1
                    x:x
                    y:-10
                    angle: vars.angle

        result.path = result.path.concat('drop')

        #_dump result.score
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


worker.addEventListener 'message',
    (e)->
        data = e.data;
        triggers[data.trigger](data.vars, data.callback) if triggers[data.trigger]?
    , false