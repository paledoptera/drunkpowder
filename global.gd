extends Node

enum COLOR_ENUM {BLUE, RED, GREEN}
const COLOR = [Color("6a98ff"), Color("ff4d3c"), Color("00ff09")]

var level: Level
var level_num: int = 1
var health_max: int = 3
var health: int

var score : int

var paused : bool = false
var ui_cursor : Node
var pause_menu : Node

func _ready() -> void:
	health = health_max
	var temp = load("res://entities/effects/cursor_effect/menu_cursor.tscn")
	ui_cursor = temp.instantiate()
	ui_cursor.levelbound = false
	add_child(ui_cursor)
	ui_cursor.hide()
	
	temp = load("res://scenes/menus/pause_menu.tscn")
	pause_menu = temp.instantiate()
	add_child(pause_menu)
	pause_menu.hide()
	pause_menu.process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	if level == null:
		pause_menu.hide()
		pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
	if Input.is_key_label_pressed(KEY_R):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("pause") and level != null:
		toggle_pause()

func toggle_pause():
	paused = not paused
	if paused:
		level.process_mode = Node.PROCESS_MODE_DISABLED
		level.modulate = Color(0.6, 0.6, 0.6, 1.0)
		level.cursor.hide()
		ui_cursor.show()
		ui_cursor.update()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		pause_menu.show()
		pause_menu.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		level.process_mode = Node.PROCESS_MODE_INHERIT
		level.modulate = Color.WHITE
		level.cursor.show()
		level.cursor.update()
		ui_cursor.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		pause_menu.hide()
		pause_menu.process_mode = Node.PROCESS_MODE_DISABLED

func damage(value: int) -> void:
	health -= value
	health = max(health,0)
	level.camera_shake(8)
