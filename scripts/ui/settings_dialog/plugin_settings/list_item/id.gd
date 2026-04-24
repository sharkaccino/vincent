extends Label

@onready var plugin_id = get_node("../../../../../../").get_meta("id")

# TODO: hide this with debug menu option

func _ready() -> void:
	if plugin_id == "":
		return
	
	var plugin = PluginManager.get_plugin(plugin_id)
	if "metadata" not in plugin:
		printerr("Could not get plugin data for id: \"", plugin_id, "\"")
		return
	
	if plugin.builtin:
		text = "(built-in)"
	else:
		text = plugin_id
		
	var url = PluginManager.get_value_or_null(plugin.metadata, "url")
	var version = PluginManager.get_value_or_null(plugin.metadata, "version")

	if url == null && version == null:
		size_flags_vertical = Control.SIZE_EXPAND_FILL
