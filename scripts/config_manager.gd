extends Node

const _config_path_relative = "user://config.json"
var config_path = ProjectSettings.globalize_path(_config_path_relative)
const _default_config_path = "res://resources/default_config.json"
const _default_config: JSON = preload(_default_config_path)

signal config_updated

var _current_config = _default_config.data

func update_config(new_data: Dictionary) -> Error:
	var file = FileAccess.open(config_path, FileAccess.WRITE)
	
	if file == null:
		return FileAccess.get_open_error()
		
	file.store_string(JSON.stringify(new_data))
	file.close()
	config_updated.emit(new_data)
	return Error.OK

func get_config() -> Dictionary:
	return _current_config

func _ready() -> void:
	if FileAccess.file_exists(config_path):
		var json_string = FileAccess.get_file_as_string(config_path)
		var json = JSON.parse_string(json_string)
		
		if json == null:
			push_error("Could not parse configuration file.")
		else:
			_current_config = json
			print("loaded config: ", json)
	else:
		var file = FileAccess.open(config_path, FileAccess.WRITE)
		
		if file == null:
			push_error(FileAccess.get_open_error())
			return
		
		file.store_string(JSON.stringify(_default_config.data))
		file.close()
		print("default config loaded")
