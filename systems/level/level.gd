extends Node2D
class_name Level


@export var sections: Array[LevelSection]
@export var timer: Timer
@export var parent_bombs: Node

var spawnpoints: Array[Spawnpoint]
var zones: Array[Zone]


func _ready() -> void:
	# Setting up node groups
	for zone in get_tree().get_nodes_in_group("zone"):
		zones.append(zone)
	
	for spawnpoint in get_tree().get_nodes_in_group("spawnpoint"):
		spawnpoints.append(spawnpoint)
	
	# Setting timer
	timer.timeout.connect(_on_timer_timeout)
	timer.start(3.0)


func load_level_section() -> void:
	
	var section = sections[0]
	for data in section.data_pool:
		for ind in range(data.amount):
			section.pool.append(data.scene)
	section.pool.shuffle()
	section.loaded = true


func _on_timer_timeout() -> void:
	
	if sections.size() == 0:
		end()
		return
	
	var section = sections[0] # Getting the first array in the queue

	if not section.loaded:
		load_level_section()
	
	timer.start(section.delay_between_spawns)
	
	if sections[0].pool.size() == 0:
		sections.pop_front()
		return
	
	var spawnpoint = spawnpoints.pick_random()
	var bomb = section.pool.pop_front().instantiate()
	parent_bombs.add_child(bomb)
	bomb.global_transform = spawnpoint.global_transform


func end() -> void:
	print("END")
