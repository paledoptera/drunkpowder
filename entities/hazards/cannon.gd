extends Node2D
class_name Cannon

enum Mode {RANDOM, CYCLIC, ALL}



var spawnpoints: Array[Spawnpoint]
@export var firing_mode: Mode = Mode.RANDOM
@export var fireball_scene: PackedScene = preload("uid://cgftmw3myjbtv")
@export var firing_delay: float = 5.0
var spawnpoint_ind = 0

func _ready() -> void:
	for spawnpoint in get_children():
		if spawnpoint.is_in_group("hazard_spawnpoint"):
			spawnpoints.append(spawnpoint)
	
	$Timer.start(firing_delay)

func _on_timer_timeout() -> void:
	if Global.level.ended:
		return
	match firing_mode:
		Mode.RANDOM:
			var spawnpoint = spawnpoints.pick_random()
			spawn_fireball(spawnpoint.global_position,spawnpoint.direction, spawnpoint.velocity)
		
		Mode.CYCLIC:
			spawnpoint_ind += 1
			spawnpoint_ind = wrapi(spawnpoint_ind,0,spawnpoints.size())
			var spawnpoint = spawnpoints[spawnpoint_ind]
			spawn_fireball(spawnpoint.global_position,spawnpoint.direction, spawnpoint.velocity)
			
		Mode.ALL:
			for spawnpoint in spawnpoints:
				spawn_fireball(spawnpoint.global_position,spawnpoint.direction, spawnpoint.velocity)


func spawn_fireball(fireball_position: Vector2, direction:= Vector2.DOWN, speed: float = 70.0):
	
	var fireball = fireball_scene.instantiate()
	
	Audio.play_sfx(preload("uid://d35nm56eiofii"),true,randf_range(0.5,1.5))
	Audio.play_sfx(preload("uid://cajmbf4vkr4su"),true,randf_range(1.5,2.0))
	
	Global.level.parent_bombs.add_child(fireball)
	fireball.direction = direction
	fireball.speed = speed
	fireball.global_position = fireball_position
