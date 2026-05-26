class_name Bomb
extends CharacterBody2D


const EXPLODE_SCENE = preload("uid://ypu58akmjecd")
const SMOKEPUFF_SCENE = preload("uid://bgwfebdgtnu3v")
var DEFUSED_SCENE = preload("uid://cqpms1sg3jqih")

@export var area: Area2D
@export var sprite: Sprite2D
@export var progress : Sprite2D
@export var color: Global.BOMB_TYPE
@export var fuse: float = 12.5


var direction : Vector2
var speed : float = 50.0
var speed_mult: float = 1.0
@onready var fuse_progress : float = fuse
var in_stasis : bool = false

var mouse_hovering: bool = false
var held: bool = false
var held_offset := Vector2.ZERO
var area_inside: Area2D
var rotate_sign: int = 1

var initial_progress_height : int
var initial_progress_position : Vector2
var initial_progress_y : int
var i_count : int

var defused_bomb: Node
var fuse_lit: bool = false

func _ready() -> void:
	rotate_sign = [-1,1].pick_random()
	initial_progress_position = progress.position
	initial_progress_height = progress.region_rect.size.y
	initial_progress_y = progress.region_rect.position.y
	
	if Global.level:
		if not Global.level.await_visible_on_screen:
			## Visible on screen check
			# If a zone of a matching color isn't visible on screen, then delay the
			# spawn until it is.
			# This is so it's always possible to get a perfect sorting score
			# on levels like level8, where a color might be
			# slightly offscreen for a few seconds.
			var correct_zone: Zone
			for zone in Global.level.zones:
				if zone.color == color:
					correct_zone = zone
					break
			if correct_zone:
				if not correct_zone.visible_on_screen:
					await correct_zone.entered_screen
	fuse_lit = true
	

func _physics_process(delta: float) -> void:
	
	
	if in_stasis:
		if mouse_hovering:
			$Target.show()
		else:
			$Target.hide()
		return
	
	if fuse_lit:
		fuse_progress = move_toward(fuse_progress,0.0,delta)
	progress.position = initial_progress_position
	progress.region_rect.size.y = int(fuse_progress/fuse*initial_progress_height)
	progress.region_rect.position.y = (initial_progress_y + initial_progress_height - progress.region_rect.size.y)
	progress.offset = sprite.offset
	progress.offset.y += (initial_progress_height - progress.region_rect.size.y)
	if fuse_progress/fuse < 0.2:
		if i_count == 0:
			Audio.play_sfx(load("res://sfx/snd_warning.ogg"),true)
			if sprite.modulate == Color.WHITE:
				sprite.modulate = Color.YELLOW
			else:
				sprite.modulate = Color.WHITE
	else:
		sprite.modulate = Color.WHITE
	if i_count == 0:
		i_count = 6
		Audio.play_sfx(load("res://sfx/Sssss.ogg"),true)
	else: i_count -= 1
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
	
	if area.has_overlapping_areas():
		check_sort()
	
	
	speed = lerp(speed,40.0,0.05)
	speed_mult = speed/40.0
	direction = direction.rotated(rotate_sign*0.01*(0.9+(speed_mult/10)))
	
	if mouse_hovering:
		$Target.show()
	else:
		$Target.hide()
	
	var collision = move_and_collide(direction * speed * delta)
	if collision: 
		direction = direction.bounce(collision.get_normal())


func drag(delta) -> void:
	$Target.hide()
	
	var prev_pos = position
	global_position = get_global_mouse_position() - held_offset + Vector2(15,15)
	
	held_offset = held_offset.lerp(Vector2(15,10),10.0*delta)
	
	if position - prev_pos != Vector2.ZERO: 
		direction = (position - prev_pos)
		speed = lerp(speed,(position-prev_pos).length()/delta,0.1)
	
	


func pick_up(offset: Vector2) -> void:
	in_stasis = false
	if get_parent() is StasisPoint:
		get_parent().bomb_in_stasis = null
		get_parent().set_collision_layer_value(2,true)
		
		reparent(Global.level.parent_bombs)
		
	
	Audio.play_sfx(preload("uid://by4u06xpmrt2k"),true,randf_range(0.8,1.2))
	z_index = 400
	z_as_relative = false
	y_sort_enabled = false
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	held = true
	held_offset = offset
	$AnimationPlayer.play("pick_up")
	Global.holding_item = self

func drop() -> void:
	z_index = 0
	z_as_relative = true
	y_sort_enabled = true
	held = false
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)
	$AnimationPlayer.play_backwards("pick_up")
	$AnimationPlayer.queue("move")
	Global.holding_item = null
	Audio.play_sfx(preload("uid://by4u06xpmrt2k"),true,randf_range(0.8,1.2))


func check_sort():
	if not area.has_overlapping_areas():
		return
	
	for zone in area.get_overlapping_areas():
		if zone is StasisPoint:
			zone.set_collision_layer_value(2,false)
			in_stasis = true
			reparent(zone)
			zone.bomb_in_stasis = self
			zone.bomb_entered_stasis.emit(self,zone)
			$AnimationPlayer.play("stasis")
			set_collision_layer_value(1,false)
			set_collision_mask_value(1, false)
		
		
		if zone is Zone:
			if zone.color == color:
				if zone.ignited:
					return
				defuse(zone)
				return
			else:
				dropped_in_wrong_area(zone)
				return
			

func dropped_in_wrong_area(zone: Zone):
	explode()


func explode(damage: bool = true) -> void:
	Global.score = clampi(Global.score-20,0,999999999)
	if damage:
		Global.damage(1)
	Global.level.create_particle(SMOKEPUFF_SCENE,global_position,get_parent())
	Global.level.create_particle(EXPLODE_SCENE,global_position+Vector2(0.0,-6.0),get_parent())
	Audio.play_sfx(load("res://sfx/Box Explosion.ogg"))
	Global.level.reset_fuses()
	queue_free()

func defuse(zone: Zone) -> void:
	Audio.play_sfx(load("res://sfx/Thud 2.wav")).pitch_scale = randf_range(0.8,1.2)
	defused_bomb = DEFUSED_SCENE.instantiate()
	zone.add_child(defused_bomb)
	defused_bomb.color = color
	defused_bomb.global_position = ceil(global_position)
	defused_bomb.texture = sprite.texture
	defused_bomb.hframes = sprite.hframes
	defused_bomb.frame = sprite.frame
	defused_bomb.scale = sprite.scale
	defused_bomb.z_index = 1
	var neo_progress = progress.duplicate()
	neo_progress.position = initial_progress_position
	neo_progress.region_rect.size.y = int(fuse_progress/fuse*initial_progress_height)
	neo_progress.region_rect.position.y = (initial_progress_y + initial_progress_height - neo_progress.region_rect.size.y)
	neo_progress.offset = Vector2.ZERO
	neo_progress.offset.y += (initial_progress_height - neo_progress.region_rect.size.y)
	defused_bomb.add_child(neo_progress)
	defused_bomb.fuse = fuse
	defused_bomb.fuse_progress = fuse_progress
	defused_bomb.zone = zone
	call_deferred("queue_free")


func off_screen() -> void:
	if get_parent() is not Zone and get_parent() is not StasisPoint:
		queue_free()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			pick_up(event.position)
		else:
			drop()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed and held:
			drop()


func _on_place_buffer_timeout() -> void:
	check_sort()


func _on_mouse_entered() -> void:
	mouse_hovering = true


func _on_mouse_exited() -> void:
	mouse_hovering = false


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	off_screen()
