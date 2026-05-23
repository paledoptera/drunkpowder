extends Resource
class_name LevelSection

enum Mode {RANDOM, CYCLIC, ALL}

@export var data_pool: Array[LevelBombData]
@export var delay_between_spawns: float = 0.66
@export var spawn_mode: Mode = Mode.RANDOM
@export var await_board_clear: bool = false
@export var refresh_board: bool = false
@export var level_break: bool = false
var loaded: bool = false
var pool: Array[int]
