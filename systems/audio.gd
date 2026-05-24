extends Node

var music_player : AudioStreamPlayer
var fading = false

var sfx_array : Array[AudioStreamPlayer]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
func _process(_delta: float) -> void:
	if fading:
		return
	music_player.volume_linear = Global.music_volume * 0.25
	
func play_music(audio: AudioStream):
	if audio == music_player.stream:
		return
	music_player.stop()
	music_player.stream = audio
	music_player.play()
	
func stop_music():
	music_player.stream = null
	music_player.stop()
	
func fade_music():
	if Global.music_volume == 0:
		return
	var tween = create_tween()
	tween.tween_property(music_player,"volume_linear",0,0.8)
	fading = true
	await tween.finished
	music_player.stop()
	fading = false
	
func play_sfx(audio: AudioStream, prevent_stacking = false, pitch: float = 1.0) -> AudioStreamPlayer:
	if audio == null:
		return
	
	if prevent_stacking:
		for player in sfx_array:
			if player.stream == audio and player.get_playback_position() < 0.1:
				return null
	
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = audio
	sfx_player.volume_linear = Global.sfx_volume * 0.25
	sfx_player.pitch_scale = pitch
	sfx_player.finished.connect(_on_sound_timeout.bind(sfx_player))
	sfx_array.append(sfx_player)
	add_child(sfx_player)
	sfx_player.play()
	
	return sfx_player


func kill_all_sfx():
	for sfx in sfx_array:
		sfx.finished.disconnect(_on_sound_timeout)
		sfx.queue_free()
	sfx_array.clear()
	
func _on_sound_timeout(sfx_player : AudioStreamPlayer):
	sfx_player.finished.disconnect(_on_sound_timeout)
	sfx_array.erase(sfx_player)
	sfx_player.queue_free()
