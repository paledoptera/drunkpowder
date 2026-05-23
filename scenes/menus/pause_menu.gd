extends Node2D


func _on_continue_clicked() -> void:
	Global.toggle_pause()


func _on_quit_clicked() -> void:
	Global.toggle_pause()
	Global.goto_scene(preload("uid://cgskbsomutq37"))
	pass # Replace with function body.
