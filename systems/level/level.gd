extends Node2D
class_name Level

@export var ui_label : Label
@export var sections: Array[LevelSection]
@export var timer: Timer
@export var parent_bombs: Node
@export var actions: AnimationPlayer
@onready var camera : Camera2D = $CameraPivot/Camera2D

var spawnpoints: Array[Spawnpoint]
var zones: Array[Zone]
var no_more_bombs: bool = false
var ended: bool = false


func _ready() -> void:
	Global.level = self
	
	# Setting up node groups
	for zone in get_tree().get_nodes_in_group("zone"):
		zones.append(zone)
	
	for spawnpoint in get_tree().get_nodes_in_group("spawnpoint"):
		spawnpoints.append(spawnpoint)
	
	# Setting timer
	timer.timeout.connect(_on_timer_timeout)
	timer.start(3.0)

func _process(delta: float) -> void:
	ui_label.text = "Score: "+str(Global.score*10) + "\n"
	ui_label.text += "HP: "+str(Global.health)
	if ended:
		return
	
	if no_more_bombs and parent_bombs.get_child_count() == 0:
		end()

	

func load_level_section() -> void:
	
	var section = sections[0]
	for data in section.data_pool:
		for ind in range(data.amount):
			section.pool.append(data.scene)
	section.pool.shuffle()
	section.loaded = true


func _on_timer_timeout() -> void:
	
	if sections.size() == 0:
		no_more_bombs = true
		return
	
	var section = sections[0] # Getting the first array in the queue

	if not section.loaded:
		load_level_section()
	
	timer.start(section.delay_between_spawns)
	
	if sections[0].pool.size() == 0:
		sections.pop_front()
		return
	
	var spawnpoint = spawnpoints.pick_random()
	var bomb: Bomb = section.pool.pop_front().instantiate()
	parent_bombs.add_child(bomb)
	bomb.direction = spawnpoint.direction
	bomb.speed = spawnpoint.velocity
	bomb.global_position = spawnpoint.global_position
	

func camera_shake(length:int=4):
	while length > 0:
		camera.offset = Vector2i(randi_range(-length*2,length*2),randi_range(-length,length))
		length -= 1
		await get_tree().process_frame
		await get_tree().process_frame
	camera.offset = Vector2.ZERO

func end() -> void:
	ended = true
	$Animations.play("end")
