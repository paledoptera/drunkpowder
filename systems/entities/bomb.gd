class_name Bomb
extends CharacterBody2D

const DEFUSED_SCENE = preload("uid://cqpms1sg3jqih")
const EXPLODE_SCENE = preload("uid://ypu58akmjecd")
const SMOKEPUFF_SCENE = preload("uid://bgwfebdgtnu3v")

@export var area: Area2D
@export var sprite: Sprite2D
@onready var progress : Sprite2D = $Sprite2D/Progress
@export var color: Global.COLOR_ENUM
@export var fuse: float = 10.0

var direction : Vector2
var speed : float = 50.0
var speed_mult: float = 1.0
@onready var fuse_progress : float = fuse

var held: bool = false
var held_offset := Vector2.ZERO
var area_inside: Area2D
var rotate_sign: int = 1

var initial_progress_height : int
var initial_progress_y : int
var flash_count : int

func _ready() -> void:
	rotate_sign = [-1,1].pick_random()
	initial_progress_height = progress.region_rect.size.y
	initial_progress_y = progress.region_rect.position.y

func _physics_process(delta: float) -> void:
	fuse_progress = move_toward(fuse_progress,0.0,delta)
	progress.region_rect.size.y = fuse_progress/fuse*initial_progress_height
	progress.region_rect.position.y = initial_progress_y + (initial_progress_height - fuse_progress/fuse*initial_progress_height)
	progress.offset = sprite.offset
	progress.offset.y += (initial_progress_height - fuse_progress/fuse*initial_progress_height)
	if fuse_progress/fuse < 0.2:
		if flash_count == 0:
			flash_count = 3
			if sprite.modulate == Color.WHITE:
				sprite.modulate = Color.YELLOW
			else:
				sprite.modulate = Color.WHITE
		else: flash_count -= 1
	if fuse_progress <= 0.0:
		explode()
		return
	
	direction = direction.normalized()
	
	
	if not held:
		move(delta)
		return
	else:
		drag(delta)
	
	global_position = get_global_mouse_position() - held_offset + Vector2(15,15)

func move(delta) -> void:
	speed = lerp(speed,50.0,0.05)
	speed_mult = speed/50.0
	direction = direction.rotated(rotate_sign*0.01*(0.9+(speed_mult/10)))
	
	var collision = move_and_collide(direction * speed * delta)
	if collision: 
		direction = direction.bounce(collision.get_normal())

func drag(delta) -> void:
	var prev_pos = position
	global_position = get_global_mouse_position() - held_offset + Vector2(15,15)
	if position - prev_pos != Vector2.ZERO: 
		direction = (position - prev_pos)
		speed = lerp(speed,(position-prev_pos).length()/delta,0.1)
	


func pick_up(offset: Vector2) -> void:
	z_index = 400
	z_as_relative = false
	y_sort_enabled = false
	held = true
	held_offset = offset
	print(offset)
	held_offset = held_offset.clamp(Vector2(5.0,5.0),Vector2(25.0,25.0))
	print(offset)


func drop() -> void:
	z_index = 0
	z_as_relative = true
	y_sort_enabled = true
	held = false
	if not area.has_overlapping_areas():
		return
	
	for area in area.get_overlapping_areas():
		if area is Zone:
			if area.color == color:
				defuse(area)
			else:
				explode()
			


func explode() -> void:
	create_particle(SMOKEPUFF_SCENE)
	create_particle(EXPLODE_SCENE,Vector2(0.0,-6.0))
	
	Global.score = clampi(Global.score-5,0,999999999)
	Global.damage(1)
	queue_free()

func defuse(zone: Zone) -> void:
	var defused_bomb = DEFUSED_SCENE.instantiate()
	zone.add_child(defused_bomb)
	defused_bomb.global_transform = global_transform
	defused_bomb.texture = sprite.texture
	defused_bomb.hframes = sprite.hframes
	defused_bomb.frame = sprite.frame
	defused_bomb.scale = sprite.scale
	var neo_progress = progress.duplicate()
	neo_progress.offset.x = 0
	defused_bomb.add_child(neo_progress)
	defused_bomb.fuse = fuse
	defused_bomb.fuse_progress = fuse_progress
	queue_free()

func create_particle(particle: PackedScene, offset:= Vector2.ZERO) -> void:
	var inst = particle.instantiate()
	get_parent().add_child(inst)
	inst.emitting = true
	inst.finished.connect(inst.queue_free)
	inst.global_position = global_position + offset

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			pick_up(event.position)
		else:
			drop()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed:
			drop()
