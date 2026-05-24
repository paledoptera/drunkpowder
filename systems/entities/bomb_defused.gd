extends Sprite2D
class_name BombDefused

var color : Global.COLOR_ENUM
var fuse : float = 10.0
var fuse_progress : float = 10.0

func _ready() -> void:
	hide()
	await get_tree().process_frame
	if fuse_progress/fuse > 0.2:
		$Label.text = "+"+str(ceili(fuse_progress)*10)
		$Label.self_modulate = Color.YELLOW
		if ceili(fuse_progress) == fuse:
			$Label.text += "\nPERFECT!"
			Audio.play_sfx(load("res://sfx/sWalkMetal3.wav"))
			#Global.level.camera_shake(2)
		Global.score += ceili(fuse_progress)
	else:
		$Label.text = "+0"
		$Label.self_modulate = Color.CRIMSON
	show()
	$AnimationPlayer.play("defuse")
	await $AnimationPlayer.animation_finished

func _process(_delta: float) -> void:
	global_rotation = 0
