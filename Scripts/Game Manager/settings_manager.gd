extends Node

var settings_data : SettingsDataResource

#		%APPDATA%\Godot\app_userdata\Chronobot\game_data
var save_settings_path = "user://game_data/"
var save_file_name = "settings_data.tres"

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("keybinding", "move_left", "A")
		config.set_value("keybinding", "move_left", "Left")
		config.set_value("keybinding", "move_right", "D")
		config.set_value("keybinding", "move_right", "Right")
		config.set_value("keybinding", "jump", "W")
		config.set_value("keybinding", "jump", "Space")
		config.set_value("keybinding", "interact", "E")
		config.set_value("keybinding", "shot", "Mouse2")
		config.set_value("keybinding", "attack", "Mouse1")
		config.set_value("keybinding", "dash", "E")
		config.set_value("keybinding", "pause", "Escape")
		config.set_value("keybinding", "wallslide", "Shift")

		config.set_value("audio", "master_volume", 1.0)
		config.set_value("audio", "sfx_volume", 1.0)
		config.set_value("audio", "music_volume", 1.0)

		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)

func load_settings():
	if !DirAccess.dir_exists_absolute(save_settings_path):
		DirAccess.make_dir_absolute(save_settings_path)
	
	if ResourceLoader.exists(save_settings_path + save_file_name):
		settings_data = ResourceLoader.load(save_settings_path + save_file_name)
	
	if settings_data == null:
		settings_data = SettingsDataResource.new()
	
	if settings_data != null:
		set_window_mode(settings_data.window_mode, settings_data.window_mode_index)
		set_resolution(settings_data.resolution, settings_data.resolution_index)


func set_window_mode(window_mode : int, window_mode_index : int):
	match window_mode:
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	settings_data.window_mode = window_mode
	settings_data.window_mode_index = window_mode_index


func set_resolution(resolution : Vector2i, resolution_index : int):
	get_tree().root.content_scale_size = resolution
	settings_data.resolution = resolution
	settings_data.resolution_index = resolution_index


func get_settings() -> SettingsDataResource:
	return settings_data


func save_settings():
	ResourceSaver.save(settings_data, save_settings_path + save_file_name)
