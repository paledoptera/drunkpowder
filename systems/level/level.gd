extends Node2D
class_name Level

const BOMBS = [
	preload("res://entities/bombs/blue.tscn"), # blue.tscn
	preload("res://entities/bombs/red.tscn"), # red.tscn 
	preload("res://entities/bombs/green.tscn"), # green.tscn
	preload("res://entities/bombs/purple.tscn"), # purple.tscn
	preload("uid://cfe64yq8hvuuq"), # colorswapper.tscn
	preload("uid://dv8m7gb8dcbw1") # faulty.tscn
]

var events = [false,false,false,false,false]

@export var ui_label : RichTextLabel
@onready var ui_shadow : RichTextLabel = $CameraPivot/Camera2D/Label/Shadow
@export var sections: Array[LevelSection]
@export var number: int = 0
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
	Global.level_colors = -1
	for zone in get_tree().get_nodes_in_group("zone"):
		zones.append(zone)
		if zone.color > Global.level_colors:
			Global.level_colors = zone.color
	
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
	ui_label.text = "[color=yellow]Score [/color]"+str(Global.score*10)
	ui_shadow.text = ui_label.text
	$CameraPivot/Camera2D/Lives.text = "x"+str(Global.health)
	$CameraPivot/Camera2D/Lives/Lives2.text = $CameraPivot/Camera2D/Lives.text 
	if ended:
		return

func spawn_bomb_from_pool(spawnpoint: Spawnpoint, section: LevelSection) -> void:
	if section.pool.size() == 0:
		return
	
	var bomb_id = section.pool.pop_front()
	spawn_bomb(bomb_id,spawnpoint.global_position,spawnpoint.direction,spawnpoint.velocity)

func spawn_bomb(type: Global.BOMB_TYPE, bomb_position: Vector2, direction:= Vector2.DOWN, speed: float = 70.0):
	
	var bomb: Bomb
	
	Audio.play_sfx(preload("uid://d35nm56eiofii"),true,randf_range(0.5,1.5))
	
	bomb = BOMBS[type].instantiate()

	parent_bombs.add_child(bomb)
	bomb.direction = direction
	bomb.speed = speed
	bomb.global_position = bomb_position

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
	await get_tree().create_timer(0.6).timeout
	Audio.play_sfx(load("res://sfx/QuestCompleteSoundSingle.wav"))
	await get_tree().create_timer(0.6).timeout
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel()
	for i in zones:
		for e in i.get_children():
			if e is ColorswapperDefused or e is FaultyDefused:
				continue
			if e is BombDefused:
				e.z_index = 2
				var pick : int = -160 if e.global_position.x < 120 else 160
				tween.tween_property(e,"global_position",e.global_position + Vector2(pick,0),randf_range(0.6,1.6))
				tween.tween_property(e,"modulate", Color.TRANSPARENT,1.8)
	await tween.finished
	for i in zones:
		for e in i.get_children():
			if e is ColorswapperDefused or e is FaultyDefused:
				continue
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
				spawn_bomb_from_pool(spawnpoint, section)
				
			LevelSection.Mode.CYCLIC:
				spawnpoint_ind += 1
				spawnpoint_ind = wrapi(spawnpoint_ind,0,spawnpoints.size())
				var spawnpoint = spawnpoints[spawnpoint_ind]
				spawn_bomb_from_pool(spawnpoint, section)
			
			LevelSection.Mode.ALL:
				for spawnpoint in spawnpoints:
					spawn_bomb_from_pool(spawnpoint, section)
		
		
		
	
	
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
			await get_tree().create_timer(3).timeout

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
		i.fuse_progress = clamp(i.fuse_progress+i.fuse/3.0,0,i.fuse)

func create_particle(particle_scene: PackedScene, particle_position: Vector2, parent: Node) -> Node:
	var particle = particle_scene.instantiate()
	parent.add_child(particle)
	particle.global_position = particle_position
	particle.emitting = true
	particle.finished.connect(particle.queue_free)
	return particle
