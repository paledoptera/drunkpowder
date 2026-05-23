extends Node2D
class_name Level

const BOMBS = [
	preload("uid://bmiyohd2inws1"), #blue.tscn
	preload("uid://bjsdyso2d4w8s"), #red.tscn
	preload("uid://h3x2t200m6id"), #green.tscn
]

@export var ui_label : Label
@export var sections: Array[LevelSection]
@export var timer: Timer
@export var parent_bombs: Node
@export var actions: AnimationPlayer
@onready var camera : Camera2D = $CameraPivot/Camera2D
@onready var cursor : Node = $Cursor

var spawnpoints: Array[Spawnpoint]
var spawnpoint_ind := 0
var zones: Array[Zone]
var ended: bool = false


func _ready() -> void:
	Global.level = self
	Global.health = Global.health_max
	Global.score = 0
	Global.ui_cursor.hide()
	
	# Setting up node groups
	for zone in get_tree().get_nodes_in_group("zone"):
		zones.append(zone)
	
	for spawnpoint in get_tree().get_nodes_in_group("spawnpoint"):
		spawnpoints.append(spawnpoint)
	
	# Setting timer
	timer.timeout.connect(_on_timer_timeout)
	timer.start(3.0)
	
	## Setting up sections
	# This is done so level sections stay the same even after reloading the level
	for section in sections:
		section.resource_local_to_scene = true
		for data in section.data_pool:
			data.resource_local_to_scene = true
		

func _process(_delta: float) -> void:
	ui_label.text = "Score: "+str(Global.score*10) + "\n"
	ui_label.text += "HP: "+str(Global.health)
	if ended:
		return

func spawn_bomb(spawnpoint: Spawnpoint, section: LevelSection) -> void:
	if section.pool.size() == 0:
		return
	
	var bomb: Bomb = BOMBS[section.pool.pop_front()].instantiate()
	parent_bombs.add_child(bomb)
	bomb.direction = spawnpoint.direction
	bomb.speed = spawnpoint.velocity
	bomb.global_position = spawnpoint.global_position

func load_level_section() -> void:
	
	var section = sections[0]
	if not section.level_break:
		for data in section.data_pool:
			for ind in range(data.amount):
				section.pool.append(data.bomb_type)
		section.pool.shuffle()
	section.loaded = true
	print("Section ", section, "loaded!")

func clear_board() -> void:
	for i in zones:
		for e in i.get_children():
			if e is BombDefused:
				e.queue_free()

func _on_timer_timeout() -> void:
	var section = sections[0] # Getting the first array in the queue
	
	if not section.loaded:
		load_level_section()
	
	## Spawning a bomb
	if section.pool.size() > 0:
		
		match section.spawn_mode:
			LevelSection.Mode.RANDOM:
				var spawnpoint = spawnpoints.pick_random()
				spawn_bomb(spawnpoint, section)
				
			LevelSection.Mode.CYCLIC:
				spawnpoint_ind += 1
				spawnpoint_ind = wrapi(spawnpoint_ind,0,spawnpoints.size())
				var spawnpoint = spawnpoints[spawnpoint_ind]
				spawn_bomb(spawnpoint, section)
			
			LevelSection.Mode.ALL:
				for spawnpoint in spawnpoints:
					spawn_bomb(spawnpoint, section)
		
		
		
	
	
	## If current section has ran out of bombs to spawn
	# This is checked a second time because spawning the bomb
	# changes the pool array by freeing the first instance
	if section.pool.size() == 0:
		# If section has this tag, wait until all bombs have been cleared 
		# before continuing with anything else.
		if section.await_board_clear and parent_bombs.get_child_count() > 0:
			await parent_bombs.no_children
		
		# Remove current section
		sections.pop_front()
		
		# If no more sections left, game has ended
		if sections.size() == 0:
			end()
			return
		
		# If current section wants to clear the board, clear the board
		if sections[0].refresh_board:
			clear_board()

	timer.start(sections[0].delay_between_spawns)

	

	

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

func reset_fuses():
	for i in parent_bombs.get_children():
		if i is not Bomb:
			continue
		i.fuse_progress = i.fuse
