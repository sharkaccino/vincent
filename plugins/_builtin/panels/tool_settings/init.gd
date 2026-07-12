extends Node

var metadata = ConfigFile.new()
const panel = preload("./scenes/tool_settings_panel.tscn")

func _ready() -> void:
	var config_path = str(get_meta("path"), "/metadata.ini")
	metadata.load(config_path)
	var plugin_id = metadata.get_value("plugin_metadata", "id")
	# TODO: localize
	PanelManager.register_panel(plugin_id, "Tool Settings", panel)
