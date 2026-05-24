extends Bomb
class_name Colorswapper

@export var emblem: Node2D
var last_color: = -1

const BOMBS = [
	preload("uid://bmiyohd2inws1"),
	preload("uid://bjsdyso2d4w8s"),
	preload("uid://h3x2t200m6id"),
	preload("res://entities/bombs/purple.tscn")
]

func _ready() -> void:
	super()
	var arr = range(Global.level_colors+1)
	arr.erase(last_color)
	
	color = arr.pick_random() as Global.COLOR_ENUM
	set_sprites(self)
	set_emblem(self)
	DEFUSED_SCENE = preload("uid://bxk3tkd4qbgvo")
	
	if not direction:
		direction = Vector2.LEFT.rotated(deg_to_rad(randf_range(0.0,360.0)))

func defuse(zone: Zone) -> void:
	super(zone)
	set_emblem(defused_bomb)


func set_sprites(node: Node) -> void:
	var source_bomb = BOMBS[color].instantiate()
	node.get_node("BombSprite").texture = source_bomb.get_node("BombSprite").texture
	node.get_node("BombSprite/ProgressSprite").texture = source_bomb.get_node("BombSprite/ProgressSprite").texture
	node.get_node("BombSprite/ProgressSprite").region_rect = source_bomb.get_node("BombSprite/ProgressSprite").region_rect
	node.get_node("BombSprite/ProgressSprite").position = source_bomb.get_node("BombSprite/ProgressSprite").position
	node.get_node("BombSprite/ProgressSprite").centered = false
	initial_progress_position = source_bomb.get_node("BombSprite/ProgressSprite").position
	initial_progress_height = source_bomb.get_node("BombSprite/ProgressSprite").region_rect.size.y
	initial_progress_y = source_bomb.get_node("BombSprite/ProgressSprite").region_rect.position.y
	node.get_node("BombSprite/SmokeParticle").color = source_bomb.get_node("BombSprite/SmokeParticle").color
	


func set_emblem(node: Node) -> void:
	match node.color:
		0:
			node.emblem.position = Vector2(0.0,-8-4.0)
		1:
			node.emblem.position = Vector2(0.0,-8-3.0)
		2:
			node.emblem.position = Vector2(0.0,-8+3.0)

func dropped_in_wrong_area():
	return
