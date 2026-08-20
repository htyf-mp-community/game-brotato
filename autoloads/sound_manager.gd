extends Node

enum Sound {
	ENEMY_HIT,
	FIRE,
	UI
}

var sound_dictionary: Dictionary[Sound, Resource] = {
	Sound.ENEMY_HIT: preload("uid://blonjlaa37md0"),
	Sound.FIRE: preload("uid://g72hyxdnaath"),
	Sound.UI: preload("uid://6nolwqlami52"),
}

@export var stream_players: Array[AudioStreamPlayer]

var settings := AudioSettings.new()

var music_enabled: bool:
	get:
		return settings.music_enabled

var sfx_enabled: bool:
	get:
		return settings.sfx_enabled


func _ready() -> void:
	settings.load_from_path()


func play_sound(type: int) -> void:
	if not settings.sfx_enabled:
		return
	var stream := get_free_stream_player()
	if not stream:
		return
	
	var audio := sound_dictionary[type]
	stream.stream = audio
	stream.pitch_scale = randf_range(0.8, 1.3)
	stream.play()


func toggle_music() -> void:
	settings.music_enabled = not settings.music_enabled
	settings.save_to_path()


func toggle_sfx() -> void:
	settings.sfx_enabled = not settings.sfx_enabled
	if not settings.sfx_enabled:
		for stream: AudioStreamPlayer in stream_players:
			if stream and stream.playing:
				stream.stop()
	settings.save_to_path()


func get_free_stream_player() -> AudioStreamPlayer:
	for stream: AudioStreamPlayer in stream_players:
		if not stream.playing:
			return stream
	
	return null
