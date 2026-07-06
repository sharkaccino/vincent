extends Node

var _config_path = "user://config.ini"

signal config_updated
signal volatile_config_updated
signal restart_required

var needs_restart = false
var _saved_config: ConfigFile
var _volatile_config: ConfigFile

func has_changes() -> bool:
	for section in _saved_config.get_sections():
		for key in _saved_config.get_section_keys(section):
			var saved_value = _saved_config.get_value(section, key)
			var volatile_value = _volatile_config.get_value(section, key)
			
			if typeof(saved_value) != typeof(volatile_value):
				return true
			
			if typeof(saved_value) == TYPE_ARRAY:
				if saved_value.size() != volatile_value.size():
					return true
				
				for item in saved_value:
					if volatile_value.has(item) == false:
						return true
				
				for item in volatile_value:
					if saved_value.has(item) == false:
						return true
			
			# TODO: iterate over dictionaries
			
			if saved_value != volatile_value:
				return true
	return false

func set_volatile_value(section: String, key: String, value: Variant) -> void:
	var prechange_check = _volatile_config.get_value(section, key, "_null")
	if typeof(prechange_check) == TYPE_STRING && prechange_check == "_null":
		printerr("Attempted to set config value for nonexistant key \"", key, "\" in section \"", section, "\"")
	elif prechange_check == value:
		return
	else:
		_volatile_config.set_value(section, key, value)
		volatile_config_updated.emit()
		#print(_volatile_config.encode_to_text())

func save_config() -> Error:
	var result = _volatile_config.save(_config_path)
	if result == Error.OK:
		_saved_config = duplicate_config(_volatile_config)
		
		config_updated.emit(_saved_config)
	return result

func reset_volatile_config() -> void:
	_volatile_config = duplicate_config(_saved_config)
	volatile_config_updated.emit()

func get_full_config() -> ConfigFile:
	return _saved_config

func get_value(section: String, key: String, default: Variant = null) -> Variant:
	return _saved_config.get_value(section, key, default)

func get_volatile_value(section: String, key: String, default: Variant = null) -> Variant:
	return _volatile_config.get_value(section, key, default)

func duplicate_config(input_config: ConfigFile) -> ConfigFile:
	var new_config = ConfigFile.new()
	new_config.parse(input_config.encode_to_text())
	return new_config

# TODO: make this fire only after changes are saved
func set_requires_restart() -> void:
	needs_restart = true
	restart_required.emit()

func _ready() -> void:
	_config_path = ProjectSettings.globalize_path(_config_path)
	
	if FileAccess.file_exists(_config_path):
		var user_config = ConfigFile.new()
		var result = user_config.load(_config_path)
		
		if result != Error.OK:
			push_error("Could not load configuration file: ", error_string(result))
		else:
			_saved_config = user_config
			_volatile_config = duplicate_config(user_config)
			print("user config successfully loaded")
	else:
		var default_config = ConfigFile.new()
		default_config.load("res://resources/default_config.ini")
		
		_saved_config = default_config
		_volatile_config = duplicate_config(default_config)
		
		var result = default_config.save(_config_path)
		if result != Error.OK:
			push_error("Could not write default configuration file: ", error_string(result))
		else:
			print("default config loaded")
