extends BombDefused
class_name FaultyDefused


func _ready() -> void:
	super()
	
	var time = randf_range(10.0,30.0)
	
	var count: int = 0
	
	for i in get_parent().get_children():
		if i is FaultyDefused:
			count += 1
	
	if Global.level.number == 8 and Global.level.events[0] == false:
		Global.level.events[0] = true
		$ReFuseTimer.start(2.5)
		return
	$ReFuseTimer.start(time/count)



func _on_re_fuse_timer_timeout() -> void:
	if Global.level.ended or Global.level.sections.size() <= 1:
		return
	
	if Global.level.number == 8 and Global.level.events[1] == false:
		Global.level.events[1] = true
		Global.level.event_anim.play("move_zones")
	var zone = get_parent()
	zone.ignite()
	Global.level.create_particle(preload("uid://bgwfebdgtnu3v"),global_position,get_parent())
	Audio.play_sfx(preload("uid://cajmbf4vkr4su"),true)
