@RES =
    AUDIO:
        GAME_MUSIC: '/audio/falling_snow.mp3'
        SHAPE_ROTATE: '/audio/rotate.mp3'
        SHAPE_DROP: '/audio/drop2.mp3'
        LINES: '/audio/lines.mp3'

@TEST_MODE = false
@INIT_TEST_VIEW = true

@POOL =
    WIDTH:  10
    HEIGHT: 25
    CELL_SIZE: 20
    CELL_MARGIN: 2

@POOL.CELL_SIZE_MARGIN = @POOL.CELL_SIZE-@POOL.CELL_MARGIN

# figure drop delay
@DROP_DELAY = 400

# figure animation time
@ANIMATE_TIME = 200

# ingame view show\hide animate time
@VIEW_ANIMATE_TIME = 200


@GAME_MODE =
    LOBBY: 0
    SINGLE_PLAYER: 1
    PLAYER_VS_CPU: 2
    CPU_VS_CPU: 3

# Score calculation formula
@CPU_FORMULA =
    CPU1: 7
    CPU2: 14

@DROP_SHAPE_OPACITY = 0.3

@SHAPES = [
    [[1,1,1,1]]
    [[4,4]
     [4,4]]
    [[0,5,0]
     [5,5,5]]
    [[0,0,6]
     [6,6,6]]
    [[7,0,0]
     [7,7,7]]

    [[2,2,0]
     [0,2,2]]
    [[0,3,3]
     [3,3,0]]

]

# max different figure angles
@SHAPE_ANGLES = [2,1,4,4,4,2,2]

# controller actions
@ACTION =
    MOVE_DOWN: 'moveDown'
    MOVE_LEFT: 'moveLeft'
    MOVE_RIGHT: 'moveRight'
    ROTATE_RIGHT: 'rotateRight'
    ROTATE_LEFT: 'rotateRight'
    DROP: 'drop'
    PAUSE: 'pause'
    GET_SCORE: 'getScore'

@AUDIO_BUFFER_SIZE = 16

# key codes
@KEY =
    UP: 38
    DOWN: 40
    LEFT: 37
    RIGHT: 39
    SPACE: 32
    TAB: 9
    ESC: 27
    ENTER: 13
    BACKSPACE: 9
    ',': 188
    '.': 190
    '/': 191
    ';': 186
    '"': 222
    '|': 220
    '[': 219
    ']': 221
    '`': 192
    '-': 189
    '+': 187
    A: 65
    B: 66
    C: 67
    D: 68
    E: 69
    F: 70
    G: 71
    H: 72
    I: 73
    J: 74
    K: 75
    L: 76
    M: 77
    N: 78
    O: 79
    P: 80
    Q: 81
    R: 82
    S: 83
    T: 84
    U: 85
    V: 86
    W: 87
    X: 88
    Y: 89
    Z: 90
    0: 48
    1: 49
    2: 50
    3: 51
    4: 52
    5: 53
    6: 54
    7: 55
    8: 56
    9: 57