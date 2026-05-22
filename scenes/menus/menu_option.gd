extends Label

class_name MenuOption

signal clicked

@export var selected_modulation : Color = Color.WHITE
@export var deselected_modulation : Color = Color.DIM_GRAY

@export var selected_offset : Vector2 = Vector2.ZERO
@export var deselected_offset : Vector2 = Vector2.ZERO

var default_position : Vector2

func _ready() -> void:
	default_position = position
	on_mouse_exited()

var mouse_overlapping : bool = false
var clicking : bool = false
func _process(_delta: float) -> void:
	if clicking:
		return
	if mouse_overlapping:
		if Input.is_action_just_pressed("click"):
			clicking = true
			await shake()
			clicked.emit()
			clicking = false
			return
		var mouse_pos = get_local_mouse_position()
		if mouse_pos.x < 0 or\
		mouse_pos.x > size.x or\
		mouse_pos.y < 0 or\
		mouse_pos.y > size.y:
			mouse_overlapping = false
			on_mouse_exited()
	else:
		var mouse_pos = get_local_mouse_position()
		if mouse_pos.x > 0 and\
		mouse_pos.x < size.x and\
		mouse_pos.y > 0 and\
		mouse_pos.y < size.y:
			mouse_overlapping = true
			on_mouse_entered()

func on_mouse_entered():
	modulate = selected_modulation
	position = default_position + selected_offset
	
func on_mouse_exited():
	modulate = deselected_modulation
	position = default_position + deselected_offset
	
func shake():
	var tween = create_tween()
	tween.tween_property(self,"scale", Vector2.ONE * 0.8, 0.03)
	tween.tween_property(self,"scale", Vector2.ONE * 1, 0.03)
	await tween.finished
