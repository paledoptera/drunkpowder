extends BombDefused
class_name FaultyDefused


func _ready() -> void:
	super()
	if Global.level.number == 9 and Global.level.events[0] == false:
		Global.level.events[0] = true
		$ReFuseTimer.start(3.0)
		return
	$ReFuseTimer.start(randf_range(10.0,30.0))



func _on_re_fuse_timer_timeout() -> void:
	if Global.level.number == 9 and Global.level.events[1] == false:
		Global.level.events[1] = true
		Global.level.event_anim.play("move_zones")
	var zone = get_parent()
	zone.ignite()
	Global.level.create_particle(preload("uid://bgwfebdgtnu3v"),global_position,get_parent())
	Audio.play_sfx(preload("uid://cajmbf4vkr4su"),true)
