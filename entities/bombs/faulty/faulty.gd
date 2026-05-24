extends Bomb
class_name Faulty

func _ready() -> void:
	super()
	DEFUSED_SCENE = preload("uid://chd7r50i6g2va")

func check_sort():
	for area in area.get_overlapping_areas():
		if area is Zone:
			if area.ignited:
				return
			defuse(area)
