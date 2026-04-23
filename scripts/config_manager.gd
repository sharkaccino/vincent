extends Node

var _config_path = "user://config.ini"

signal config_updated

var _current_config: ConfigFile

func update_config(new_data: ConfigFile) -> Error:
	var result = new_data.save(_config_path)
	if result == Error.OK:
		config_updated.emit(new_data)
	return result

func get_config() -> ConfigFile:
	return _current_config

func _ready() -> void:
	_config_path = ProjectSettings.globalize_path(_config_path)
	
	if FileAccess.file_exists(_config_path):
		var user_config = ConfigFile.new()
		var result = user_config.load(_config_path)
		
		if result != Error.OK:
			push_error("Could not load configuration file: ", error_string(result))
		else:
			_current_config = user_config
			print("user config successfully loaded")
	else:
		var default_config = ConfigFile.new()
		default_config.load("res://resources/default_config.ini")
		
		_current_config = default_config
		
		var result = default_config.save(_config_path)
		if result != Error.OK:
			push_error("Could not write default configuration file: ", error_string(result))
		else:
			print("default config loaded")
