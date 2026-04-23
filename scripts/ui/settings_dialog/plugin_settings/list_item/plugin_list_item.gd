extends PanelContainer

func _ready() -> void:
	var plugin_id = get_meta("id")
	if plugin_id == "":
		visible = false
		return
	
	var plugin = PluginManager.get_plugin(plugin_id)
	if "metadata" not in plugin:
		printerr("Could not get plugin data for id: \"", plugin_id, "\"")
		return
