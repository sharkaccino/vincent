extends Label

var count = 1

func _update_count() -> void:
	var container = get_parent()
	container.visible = count > 0
	text = "+%s unloaded" % count

func set_count(new_count: int) -> void:
	count = new_count
	_update_count()

func _ready() -> void:
	count = PluginManager.unregistered_plugin_count
	_update_count()
