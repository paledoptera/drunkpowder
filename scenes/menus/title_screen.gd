extends Node2D

@export var anim: AnimationPlayer

@export var level_buttons_parent: Node

const LEVEL_SCENES = [
	preload("uid://c0vmvyvr4a3fs"), # level1.tscn
	preload("uid://c06lcbdnm8ndj"), # level2.tscn
	preload("uid://bqwop3lig75a8"), # level3.tscn
	preload("uid://duq3jaaounanm"), # level4.tscn
	preload("uid://8mjrn4s6y11c"), #level5.tscn
	preload("uid://dxrdamcvg5g17"), #level6.tscn
	preload("res://scenes/levels/level7.tscn"), #level7.tscn
	preload("res://scenes/levels/level8.tscn"), #level8.tscn
	preload("uid://vrgfxo1eskhc"), #level9.tscn
	preload("uid://cqwj1yfg2pkb8"), #level10.tscn
	null,
	null,
	null,
	null,
	preload("uid://0mlues1tjls1"), #level15.tscn
]

func _ready() -> void:
	for i in level_buttons_parent.get_children():
		if i is not Button:
			continue
		i.pressed.connect(_on_level_button_pressed.bind(i))
	
	await get_tree().process_frame
	Global.ui_cursor.show()
	Global.ui_cursor.update()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if Global.level_screen_open:
		$LevelScreen.position.y = 0.0

func _on_play_pressed() -> void:
	anim.stop()
	anim.play("pan_to_levels")
	Global.level_screen_open = true

func _on_level_button_pressed(node: Node) -> void:
	var level_num = int(node.name)
	if level_num > LEVEL_SCENES.size():
		return
	
	Global.goto_scene(LEVEL_SCENES[level_num-1])
