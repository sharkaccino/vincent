extends Button

@onready var plugin_settings_container = %PluginSettings
@onready var dialog = $FileDialog

func _handle_file_selection(paths: PackedStringArray) -> void:
	var plugins_dir = ProjectSettings.globalize_path(PluginManager.user_plugins_dir)
	var copied_count = 0
	var unloaded_counter = %UnloadedPluginsLabel
	
	for path in paths:
		var result = DirAccess.copy_absolute(path, str(plugins_dir, "/", path.get_file()))
		if result != Error.OK:
			printerr("Could not copy plug-in from \"", path, "\" (", error_string(result), ")")
		else: copied_count += 1
	
	if copied_count > 0:
		ConfigManager.set_requires_restart()
		unloaded_counter.set_count(unloaded_counter.count + copied_count)

func _pressed() -> void:
	dialog.visible = true

func _ready() -> void:
	await plugin_settings_container.ready
	
	dialog.files_selected.connect(_handle_file_selection)
