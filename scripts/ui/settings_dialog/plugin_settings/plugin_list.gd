extends VBoxContainer

@onready var plugin_item_template = $PluginItemTemplate

func _ready() -> void:
	var all_plugins = PluginManager.registered_plugins
	
	for plugin in all_plugins:
		var plugin_id = plugin.metadata.get_value("plugin_metadata", "id")
		var list_item = plugin_item_template.duplicate()
		list_item.set_meta("id", plugin_id)
		list_item.visible = true
		add_child(list_item)
