extends BombDefused
class_name ColorswapperDefused

@export var emblem: Node2D

func _ready() -> void:
	super()
	$ReFuseTimer.start(randf_range(5.0,20.0))




func _on_re_fuse_timer_timeout() -> void:
	
	var new_bomb = load("uid://cfe64yq8hvuuq").instantiate()
	new_bomb.last_color = int(color)
	Global.level.parent_bombs.add_child(new_bomb)
	new_bomb.global_position = global_position
	
	var particle = load("uid://dc8f55vdbb1oo").instantiate()
	new_bomb.add_child(particle)
	particle.finished.connect(particle.queue_free)
	queue_free()
