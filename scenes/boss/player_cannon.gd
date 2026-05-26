extends Node2D
class_name PlayerCannon

@export var pattern = [null,null,null]
var active: bool = false

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	
	if pattern == Global.level.current_pattern:
		for i in [$Slot1,$Slot2,$Slot3]:
			i.bomb_in_stasis.queue_free()
			i.bomb_in_stasis = null
		active = false
		$AnimationPlayer.play("blast")


func _on_bomb_entered_stasis(bomb: Bomb, stasis_point: StasisPoint) -> void:
	var ind = 0
	
	var col = bomb.color
	
	match stasis_point.name:
		"Slot1":
			ind = 0
		"Slot2":
			ind = 1
		"Slot3":
			ind = 2
	
	pattern[ind] = col
	
	pass # Replace with function body.

func damage_boss() -> void:
	Audio.play_sfx(preload("uid://c6qwyf5dj7rk8"))
	Global.level.camera_shake(8)
	Global.level.actions.stop()
	Global.level.actions.play("camera_shake")
	await get_tree().create_timer(2.0).timeout
	Global.level.current_stage = null
	Global.level._on_timer_timeout()
