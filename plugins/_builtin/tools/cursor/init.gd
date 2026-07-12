extends Node

# TODO

# purpose of this tool is mainly to manipulate selection 
# areas, but also to act as a starting tool that does 
# basically nothing when starting the app.

var metadata = ConfigFile.new()
const icon_path = preload("res://resources/icons/panel_tools/pointer.svg")
const panel = preload("./scenes/cursor_settings.tscn")

func _ready() -> void:
	var config_path = str(get_meta("path"), "/metadata.ini")
	metadata.load(config_path)
	var plugin_id = metadata.get_value("plugin_metadata", "id")
	ToolManager.register(plugin_id, icon_path, panel)
