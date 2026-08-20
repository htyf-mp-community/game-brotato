@tool
extends McpTestSuite


func suite_name() -> String:
	return "mute_persist"


func _settings():
	var script := load("res://autoloads/audio_settings.gd")
	assert_true(script != null, "AudioSettings script should exist")
	if script == null:
		return null
	return script


func test_audio_defaults_are_both_on() -> void:
	var settings_script = _settings()
	if settings_script == null:
		return
	var settings = settings_script.new()
	assert_true(settings.music_enabled)
	assert_true(settings.sfx_enabled)


func test_bgm_plays_only_when_music_on_and_pause_closed() -> void:
	var settings_script = _settings()
	if settings_script == null:
		return
	assert_true(settings_script.should_play_bgm(true, false))
	assert_false(settings_script.should_play_bgm(true, true))
	assert_false(settings_script.should_play_bgm(false, false))
	assert_false(settings_script.should_play_bgm(false, true))


func test_mute_button_labels_show_on_off() -> void:
	var settings_script = _settings()
	if settings_script == null:
		return
	assert_eq(settings_script.music_button_text(true), "音乐 开")
	assert_eq(settings_script.music_button_text(false), "音乐 关")
	assert_eq(settings_script.sfx_button_text(true), "音效 开")
	assert_eq(settings_script.sfx_button_text(false), "音效 关")


func test_config_roundtrip_keeps_only_music_and_sfx() -> void:
	var settings_script = _settings()
	if settings_script == null:
		return
	var settings = settings_script.new()
	settings.music_enabled = false
	settings.sfx_enabled = false
	var cfg := ConfigFile.new()
	settings.write_to(cfg)
	assert_eq(cfg.get_value("audio", "music"), false)
	assert_eq(cfg.get_value("audio", "sfx"), false)
	assert_false(cfg.has_section_key("audio", "coins"))
	var loaded = settings_script.new()
	loaded.read_from(cfg)
	assert_false(loaded.music_enabled)
	assert_false(loaded.sfx_enabled)


func test_missing_config_keeps_defaults_on() -> void:
	var settings_script = _settings()
	if settings_script == null:
		return
	var loaded = settings_script.new()
	loaded.music_enabled = false
	loaded.sfx_enabled = false
	loaded.read_from(ConfigFile.new())
	assert_true(loaded.music_enabled)
	assert_true(loaded.sfx_enabled)


func test_arena_music_does_not_autoplay() -> void:
	var packed: PackedScene = load("res://scenes/arena/arena.tscn")
	assert_true(packed != null, "arena scene should load")
	if packed == null:
		return
	var arena: Node = packed.instantiate()
	var music: AudioStreamPlayer = arena.get_node_or_null("MusicPlayer")
	assert_true(music != null, "arena should have MusicPlayer")
	if music != null:
		assert_false(music.autoplay, "MusicPlayer must start from saved music setting, not autoplay")
	arena.free()
