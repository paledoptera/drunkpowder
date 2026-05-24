extends Node2D
var levelbound : bool = true

func _ready() -> void:
	if levelbound:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED_HIDDEN)

func _process(_delta: float) -> void:
	update()
	
func update():
	global_position = get_global_mouse_position()
	if not levelbound:
		return
	if Input.is_action_just_pressed("click"):
		Audio.play_sfx(preload("uid://c3qnjmaeuea10"),true,randf_range(0.8,1.25))
	if Input.is_action_pressed("click"):
		$Sprite2D.frame = 1
	else:
		$Sprite2D.frame = 0



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Fireball:
		if Global.holding_item:
			Global.holding_item.explode()
		area.destroy()
