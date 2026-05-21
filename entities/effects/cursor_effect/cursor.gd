extends Node2D

func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	if Input.is_action_pressed("click"):
		$Sprite2D.frame = 1
	else:
		$Sprite2D.frame = 0
