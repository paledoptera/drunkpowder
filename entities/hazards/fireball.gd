extends Area2D
class_name Fireball

var direction : Vector2 = Vector2.DOWN
var speed : float = 50.0


func _physics_process(delta: float) -> void:
	$Sprite2D.rotate(10.0 * delta)
	global_position += direction*speed*delta
	


func _on_area_entered(area: Area2D) -> void:
	if area is Zone:
		area.ignite()
		destroy()

func destroy() -> void:
	Global.level.create_particle(preload("uid://dc3fwdtj1hyaj"),global_position,Global.level)
	var sound = [preload("uid://cjqvhen2whk4c"), preload("uid://v3vqgbmi2spw")].pick_random()
	Audio.play_sfx(sound,true,randf_range(1.2,1.5))
	Audio.play_sfx(preload("uid://by0l4dl0km7gh"),true)
	queue_free()
