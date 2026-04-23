extends Button

var _plugins_dir = ProjectSettings.globalize_path(PluginManager.user_plugins_dir)

func _pressed() -> void:
	OS.shell_open(_plugins_dir)
