extends Sprite2D
class_name BombDefused

var color : Global.BOMB_TYPE
var fuse : float = 12.5
var fuse_progress : float = 12.5

var zone : Zone

func _ready() -> void:
	hide()
	await get_tree().process_frame
	if fuse_progress/fuse > 0.2:
		print("FUSE = ", fuse_progress/fuse)
		$Label.text = "+"+str(ceili(fuse_progress)*10)
		$Label.self_modulate = Color.YELLOW

		print(fuse_progress, "/",round(fuse)-2)
		if fuse_progress >= round(fuse)-1.75:
			
			$Label.text += "\nPERFECT!"
			Audio.play_sfx(load("res://sfx/sWalkMetal3.wav"))
			#Global.level.camera_shake(2)
		Global.score += ceili(fuse_progress)
	else:
		$Label.text = "+0"
		$Label.self_modulate = Color.CRIMSON
	$Label/Label2.text = $Label.text
	show()
	$AnimationPlayer.play("defuse")
	await $AnimationPlayer.animation_finished

func _process(_delta: float) -> void:
	global_rotation = 0
