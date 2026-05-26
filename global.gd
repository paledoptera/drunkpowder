extends Node

enum BOMB_TYPE {BLUE, RED, GREEN, PURPLE, COLORSWAP, FAULTY}



#const COLOR = [Color("6a98ff"), Color("ff4d3c"), Color("00ff09")]

var music_volume : int = 2:
	set(value):
		music_volume = clamp(value,0,4)
var sfx_volume : int = 4:
	set(value):
		sfx_volume = clamp(value,0,4)

var level: Level
var level_num: int = 0
var health_max: int = 5
var health: int = 5
var holding_item: Node
var save:= PlayerSave.new()
var pause_pos: Vector2 = Vector2.ZERO

var score : int

var paused : bool = false
var ui_cursor : Node
var pause_menu : Node
var display: Node
var current_scene: Node
var level_screen_open: bool = false
var level_colors: int = 0

const LEVEL_SCENES = [
	preload("uid://c0vmvyvr4a3fs"), # level1.tscn
	preload("uid://c06lcbdnm8ndj"), # level2.tscn
	preload("uid://bqwop3lig75a8"), # level3.tscn
	preload("uid://duq3jaaounanm"), # level4.tscn
	preload("uid://8mjrn4s6y11c"), # level5.tscn
	preload("uid://dxrdamcvg5g17"), # level6.tscn
	preload("res://scenes/levels/level7.tscn"), # level7.tscn
	preload("res://scenes/levels/level8.tscn"), # level8.tscn
	preload("uid://vrgfxo1eskhc"), # level9.tscn
	preload("uid://cqwj1yfg2pkb8"), # level10.tscn
	preload("uid://bu7kjeieqj426"), # level11.tscn
	preload("uid://bedhapwd1wtd7"), # level12.tscn
	preload("uid://dnpjh8xc3tvfl"), # level13.tscn
	preload("uid://0mlues1tjls1"), # level14.tscn
	preload("uid://bc3fhd6w6py44"), # level15.tscn
	preload("uid://b07fh4gvu72ms"), # level16.tscn
]

const VICTORY_SCENE = preload("uid://bleej8jr7ih4x")
const GAMEOVER_SCENE = preload("uid://dujvx58vgn63w")

func _ready() -> void:
	await get_tree().process_frame
	display = Node.new()
	display.name = "Display"
	current_scene = get_tree().current_scene
	get_tree().root.add_child(display)
	current_scene.reparent(display)
	
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
	# debug
	if Input.is_key_label_pressed(KEY_R):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("pause") and level != null:
		toggle_pause()
	
	# checking if in a level or not
	if level == null:
		pause_menu.hide()
		pause_menu.process_mode = Node.PROCESS_MODE_DISABLED


func toggle_pause():
	paused = not paused
	if paused:
		pause_pos = get_viewport().get_mouse_position()
		level.process_mode = Node.PROCESS_MODE_DISABLED
		level.modulate = Color(0.6, 0.6, 0.6, 1.0)
		level.cursor.hide()
		ui_cursor.show()
		ui_cursor.update()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		pause_menu.global_position = current_scene.get_viewport().get_camera_2d().get_screen_center_position()-Vector2(240/2,160/2)
		pause_menu.show()
		pause_menu.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		if pause_pos:
			get_viewport().warp_mouse(pause_pos)
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
	level.actions.stop()
	level.actions.play("camera_shake")

func goto_scene(new_scene:PackedScene) -> Node:
	current_scene.queue_free()
	await current_scene.tree_exited
	var scene := new_scene.instantiate()
	display.add_child(scene)
	current_scene = scene
	return scene

func death() -> void:
	level = null
	goto_scene(GAMEOVER_SCENE)

func victory() -> void:
	if score > save.high_score[level_num]:
		save.high_score[level_num] = score
	goto_scene(VICTORY_SCENE)
