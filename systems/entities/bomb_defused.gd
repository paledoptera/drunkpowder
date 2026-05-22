extends Sprite2D

var fuse : float = 10.0
var fuse_progress : float = 10.0

func _ready() -> void:
	hide()
	await get_tree().process_frame
	$Label.text = "+"+str(ceili(fuse_progress)*10)
	if ceili(fuse_progress) == fuse:
		$Label.text += "\nPERFECT!"
		Global.level.camera_shake(2)
	Global.score += ceili(fuse_progress)
	show()
	$AnimationPlayer.play("defuse")
	await $AnimationPlayer.animation_finished

func _process(delta: float) -> void:
	global_rotation = 0
