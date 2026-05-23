extends Node2D

var last_child_count: int = 0

signal no_children

func _process(delta: float) -> void:
	if get_child_count() != last_child_count:
		last_child_count = get_child_count()
		if get_child_count() == 0:
			no_children.emit()
