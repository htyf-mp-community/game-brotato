class_name AudioSettings
extends RefCounted

const SECTION := "audio"
const KEY_MUSIC := "music"
const KEY_SFX := "sfx"
const PATH := "user://audio.cfg"

var music_enabled := true
var sfx_enabled := true


static func should_play_bgm(music_on: bool, pause_open: bool) -> bool:
	return music_on and not pause_open


static func music_button_text(music_on: bool) -> String:
	return "音乐 开" if music_on else "音乐 关"


static func sfx_button_text(sfx_on: bool) -> String:
	return "音效 开" if sfx_on else "音效 关"


func write_to(cfg: ConfigFile) -> void:
	cfg.set_value(SECTION, KEY_MUSIC, music_enabled)
	cfg.set_value(SECTION, KEY_SFX, sfx_enabled)


func read_from(cfg: ConfigFile) -> void:
	music_enabled = bool(cfg.get_value(SECTION, KEY_MUSIC, true))
	sfx_enabled = bool(cfg.get_value(SECTION, KEY_SFX, true))


func load_from_path(path: String = PATH) -> void:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return
	read_from(cfg)


func save_to_path(path: String = PATH) -> void:
	var cfg := ConfigFile.new()
	write_to(cfg)
	cfg.save(path)
