extends CheckBox

@onready var plugin_settings_container = %PluginSettings

var plugin_list: VBoxContainer

func _check_toggle_state() -> void:
	button_pressed = ConfigManager.get_volatile_value("plugins", "enabled")
	_check_fade_state()

func _check_fade_state() -> void:
	if button_pressed:
		plugin_list.modulate = Color(1,1,1,1)
	else:
		plugin_list.modulate = Color(1,1,1,0.5)

func _on_pressed() -> void:
	ConfigManager.set_volatile_value("plugins", "enabled", button_pressed)
	ConfigManager.set_requires_restart()
	_check_fade_state()

func _ready() -> void:
	await plugin_settings_container.ready
	plugin_list = %PluginList
	
	_check_toggle_state()
	_check_fade_state()
	
	ConfigManager.volatile_config_updated.connect(_check_toggle_state)
	pressed.connect(_on_pressed)
