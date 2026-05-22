extends Node2D
class_name Spawnpoint

@export var velocity: float = 70.0
var direction:= Vector2.ZERO

func _process(_delta: float) -> void:
	direction = global_position.direction_to($Sprite2D/Marker2D.global_position)
