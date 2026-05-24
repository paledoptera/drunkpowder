extends Resource
class_name LevelBombData


enum Type {BLUE, RED, GREEN, PURPLE, SPECIAL_COLORSWAP}

@export var amount: int = 10
@export var bomb_type: Type = Type.BLUE
