extends BombDefused
class_name FaultyDefused


func _ready() -> void:
	super()
	$ReFuseTimer.start(randf_range(5.0,20.0))



func _on_re_fuse_timer_timeout() -> void:
	var zone = get_parent()
	zone.ignite()
	Global.level.create_particle(preload("uid://bgwfebdgtnu3v"),global_position,get_parent())
	Audio.play_sfx(preload("uid://cajmbf4vkr4su"),true)
