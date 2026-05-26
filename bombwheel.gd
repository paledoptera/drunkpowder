class_name BombWheel
extends Node2D

@export var spd = 3.0


func _ready() -> void:
	pass
	#process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	rotate(spd*delta)
