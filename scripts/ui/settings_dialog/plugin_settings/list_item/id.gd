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

	if "url" not in plugin.metadata && "version" not in plugin.metadata:
		size_flags_vertical = Control.SIZE_EXPAND_FILL
