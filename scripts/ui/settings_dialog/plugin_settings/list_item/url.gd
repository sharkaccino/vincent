extends LinkButton

@onready var plugin_id = get_node("../../../../").get_meta("id")

func _ready() -> void:
	if plugin_id == "":
		return
	
	var plugin = PluginManager.get_plugin(plugin_id)
	if "metadata" not in plugin:
		printerr("Could not get plugin data for id: \"", plugin_id, "\"")
		return
	
	if "url" in plugin.metadata:
		text = plugin.metadata.url
		uri = plugin.metadata.url
	else:
		queue_free()
