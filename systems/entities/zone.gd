class_name Zone
extends Area2D

@export var color: Global.COLOR_ENUM

func _ready() -> void:
	$StaticBody2D/CollisionShape2D.shape = $CollisionShape2D.shape 
	$StaticBody2D/CollisionShape2D.position = $CollisionShape2D.position
