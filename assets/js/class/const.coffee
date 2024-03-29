@RES =
    AUDIO:
        MENU_MUSIC: '/assets/audio/falling_snow.mp3'
        GAME_MUSIC: '/assets/audio/jungle_vibes.mp3'
        WIN: '/assets/audio/win.mp3'
        FAIL: '/assets/audio/fail.mp3'
        SHAPE_ROTATE: '/assets/audio/rotate.mp3'
        SHAPE_DROP: '/assets/audio/drop2.mp3'
        LINES: '/assets/audio/lines.mp3'
        SPRITES: '/assets/img/fx.png'

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
    LOADING: 0
    LOBBY: 1
    SINGLE_PLAYER: 2
    PLAYER_VS_CPU: 3
    CPU_VS_CPU: 4

# Score calculation formula
@CPU = [{
    FORMULA: 7
    SMART: 100
    },
    {
    FORMULA: 15
    SMART: 100
    }
]

@SPELL =
    GROUND: 0


@DROP_SHAPE_OPACITY = 0.2

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

# addiction that means this cell is special
@SHAPE_SPECIAL = 50

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
