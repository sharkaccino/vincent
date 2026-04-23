extends CheckBox

@onready var plugin_settings_container = %PluginSettings

var plugin_list: VBoxContainer

func _on_pressed() -> void:
	if button_pressed:
		plugin_list.modulate = Color(1,1,1,1)
	else:
		plugin_list.modulate = Color(1,1,1,0.5)

func _ready() -> void:
	await plugin_settings_container.ready
	plugin_list = %PluginList
	pressed.connect(_on_pressed)
