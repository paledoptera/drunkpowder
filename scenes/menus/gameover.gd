extends Node2D


@export var buttons_parent: Node


func _ready() -> void:
	for i in buttons_parent.get_children():
		if i is not Button:
			continue
		i.pressed.connect(_on_button_pressed.bind(i))
	
	await get_tree().process_frame
	Global.ui_cursor.show()
	Global.ui_cursor.update()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_button_pressed(node: Node) -> void:
	
	match node.name:
		"Next":
			Global.goto_scene(Global.LEVEL_SCENES[Global.level_num+1])
		"Replay":
			Global.goto_scene(Global.LEVEL_SCENES[Global.level_num])
		"Quit":
			Global.goto_scene(preload("uid://cgskbsomutq37"))
