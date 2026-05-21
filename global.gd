extends Node

enum COLOR_ENUM {BLUE, RED, GREEN}
const COLOR = [Color("6a98ff"), Color("ff4d3c"), Color("00ff09")]

func _process(delta: float) -> void:
	if Input.is_key_label_pressed(KEY_R):
		get_tree().reload_current_scene()
