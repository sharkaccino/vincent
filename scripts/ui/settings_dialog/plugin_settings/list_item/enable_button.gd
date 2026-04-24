extends CheckBox

@onready var plugin_id = get_node("../../../../").get_meta("id")

func _check_toggle_state() -> void:
	var allow_list: Array = ConfigManager.get_volatile_value("plugins", "allow_list")
	button_pressed = allow_list.has(plugin_id)

func _pressed() -> void:
	var updated_array: Array = ConfigManager.get_volatile_value("plugins", "allow_list")
	updated_array = updated_array.duplicate()
	
	if button_pressed:
		updated_array.append(plugin_id)
	else:
		updated_array.remove_at(updated_array.find(plugin_id))
	
	ConfigManager.set_volatile_value("plugins", "allow_list", updated_array)
	ConfigManager.set_requires_restart()

func _ready() -> void:
	if plugin_id == "":
		return
	
	var plugin = PluginManager.get_plugin(plugin_id)
	if "metadata" not in plugin:
		printerr("Could not get plugin data for id: \"", plugin_id, "\"")
		return
		
	if (plugin.builtin):
		disabled = true
		button_pressed = true
	else:
		_check_toggle_state()
		ConfigManager.volatile_config_updated.connect(_check_toggle_state)
