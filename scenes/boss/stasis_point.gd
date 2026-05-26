extends Area2D
class_name StasisPoint

signal bomb_entered_stasis(bomb: Bomb, stasis_point: StasisPoint)
var bomb_in_stasis: Bomb

func _ready() -> void:
	for i in get_children():
		if i is Bomb:
			i.in_stasis = true
			i.set_collision_layer_value(1,false)
			i.set_collision_mask_value(1,false)
			bomb_in_stasis = i
			return

func _process(delta: float) -> void:
	if bomb_in_stasis:
		bomb_in_stasis.global_rotation = 0
		bomb_in_stasis.position = bomb_in_stasis.position.slerp(Vector2.ZERO,10.0*delta)
