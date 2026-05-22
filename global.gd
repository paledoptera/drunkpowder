extends Node

enum COLOR_ENUM {BLUE, RED, GREEN}
const COLOR = [Color("6a98ff"), Color("ff4d3c"), Color("00ff09")]

var level: Level
var level_num: int = 1
var health_max: int = 3
var health: int

var score : int

func _ready() -> void:
	health = health_max

func _process(delta: float) -> void:
	if Input.is_key_label_pressed(KEY_R):
		get_tree().reload_current_scene()

func damage(value: int) -> void:
	health -= value
	health = max(health,0)
	level.actions.stop()
	level.camera_shake(8)
