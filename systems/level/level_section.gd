extends Resource
class_name LevelSection

@export var data_pool: Array[LevelBombData]
@export var delay_between_spawns: float = 0.66
var loaded: bool = false
var pool: Array[PackedScene]
