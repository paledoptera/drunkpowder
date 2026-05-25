extends Node2D

@export var anim: AnimationPlayer
@export var level_buttons_parent: Node
var level_buttons: Array[LevelButton]


func _ready() -> void:
	for i in level_buttons_parent.get_children():
		if i is not LevelButton:
			continue
		i.pressed.connect(_on_level_button_pressed.bind(i))
		level_buttons.append(i)
	
	await get_tree().process_frame
	Global.ui_cursor.show()
	Global.ui_cursor.update()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if Global.level_screen_open:
		$LevelScreen.position.y = 0.0
	
	refresh_buttons()

func _on_play_pressed() -> void:
	anim.stop()
	anim.play("pan_to_levels")
	Global.level_screen_open = true

func _on_level_button_pressed(node: Node) -> void:
	var level_num = int(node.name)
	if level_num > Global.LEVEL_SCENES.size():
		return
	
	Global.goto_scene(Global.LEVEL_SCENES[level_num-1])

func refresh_buttons() -> void:
	for button in level_buttons:
		button.high_score_label.text = str(Global.save.high_score[int(button.name)-1],"0 ")


func _on_back_pressed() -> void:
	anim.stop()
	anim.play_backwards("pan_to_levels")
	Global.level_screen_open = false
