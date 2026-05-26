class_name Zone
extends Area2D

@export var color: Global.BOMB_TYPE
var ignited: bool = false:
	set(value):
		ignited = value
		$TextureRect/IgnitedOverlay.visible = value

var visible_on_screen: bool = true
signal entered_screen

func ignite() -> void:
	ignited = true
	for i in get_children():
		if i is BombDefused:
			var dir = global_position.direction_to(i.global_position)
			Global.level.spawn_bomb(i.color,i.global_position,dir,200.0)
			i.queue_free()
	$IgnitionTimer.stop()
	$IgnitionTimer.start()


func _on_ignition_timer_timeout() -> void:
	ignited = false
	
	var any_ignited_bombs = false
	
	for i in Global.level.parent_bombs.get_children():
		if i is not Bomb:
			continue
		if i.area.overlaps_area(self):
			print("KABLOEY")
			i.explode(false)
			any_ignited_bombs = true
	
	if any_ignited_bombs:
		Global.damage(1)
	
	


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	visible_on_screen = true
	entered_screen.emit()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	visible_on_screen = false
