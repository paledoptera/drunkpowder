class_name Bomb
extends CharacterBody2D

const DEFUSED_SCENE = preload("uid://cqpms1sg3jqih")

@export var area: Area2D
@export var sprite: Sprite2D
@export var color: Global.COLOR_ENUM
@export var fuse: int = 600

var direction : Vector2
var speed : float = 50.0
var speed_mult: float = 1.0

var held: bool = false
var held_offset := Vector2.ZERO
var area_inside: Area2D
var rotate_sign: int = 1

func _ready() -> void:
	rotate_sign = [-1,1].pick_random()
	if not direction:
		direction.x = randf_range(-1,1)
		direction.y = 1

func _physics_process(delta: float) -> void:
	direction = direction.normalized()
	
	
	if not held:
		move(delta)
		return
	else:
		drag(delta)
	
	
	
	global_position = get_global_mouse_position() - held_offset + Vector2(8,8)

func move(delta) -> void:
	speed = lerp(speed,50.0,0.05)
	speed_mult = speed/50.0
	direction = direction.rotated(rotate_sign*0.01*(0.9+(speed_mult/10)))
	
	var collision = move_and_collide(direction * speed * delta)
	if collision: 
		direction = direction.bounce(collision.get_normal())

func drag(delta) -> void:
	var prev_pos = position
	global_position = get_global_mouse_position() - held_offset + Vector2(8,8)
	if position - prev_pos != Vector2.ZERO: 
		direction = (position - prev_pos)
		speed = lerp(speed,(position-prev_pos).length()/delta,0.1)
	


func pick_up(offset: Vector2) -> void:
	held = true
	held_offset = offset


func drop() -> void:
	held = false
	if not area.has_overlapping_areas():
		return
	
	for area in area.get_overlapping_areas():
		if area is Zone:
			var defused_bomb = DEFUSED_SCENE.instantiate()
			area.add_child(defused_bomb)
			defused_bomb.global_transform = global_transform
			defused_bomb.texture = sprite.texture
			defused_bomb.scale = sprite.scale
			queue_free()


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
