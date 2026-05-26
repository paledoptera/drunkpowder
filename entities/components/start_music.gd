extends Node
class_name StartMusic

@export var music: AudioStream

func _ready() -> void:
	Audio.play_music(music)
