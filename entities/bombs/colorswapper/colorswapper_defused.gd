extends BombDefused
class_name ColorswapperDefused

@export var emblem: Node2D

func _ready() -> void:
	super()
	$ReFuseTimer.start(randf_range(5.0,20.0))




func _on_re_fuse_timer_timeout() -> void:
	
	if Global.level.ended:
		return
	if global_position.x < 0 or global_position.x > 240:
		$ReFuseTimer.start(randf_range(5.0,20.0))
		return
	
	var new_bomb = load("uid://cfe64yq8hvuuq").instantiate()
	new_bomb.last_color = int(color)
	Global.level.parent_bombs.add_child(new_bomb)
	new_bomb.global_position = global_position
	Audio.play_sfx(load("res://sfx/sPalantaFirework.wav"))
	
	Global.level.create_particle(load("uid://dc8f55vdbb1oo"),global_position,new_bomb)
	zone.bomb_count -= 1
	queue_free()
