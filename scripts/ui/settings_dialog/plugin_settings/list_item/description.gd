extends Label

@onready var plugin_id = get_node("../../../../../../").get_meta("id")

func _ready() -> void:
	if plugin_id == "":
		return
	
	var plugin = PluginManager.get_plugin(plugin_id)
	if "metadata" not in plugin:
		printerr("Could not get plugin data for id: \"", plugin_id, "\"")
		return
	
	if "description" in plugin.metadata:
		text = plugin.metadata.description
	else:
		queue_free()
