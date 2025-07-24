extends MenuButton

var settings_window

func _on_id_pressed(id) -> void:
	print("[edit] menu button pressed: ", id)
	if (id == 2): settings_window.popup()

func _ready() -> void:
	var popup = get_popup()
	
	settings_window = PopupManager.create("res://scenes/settings.tscn")
	settings_window.name = "SettingsDialog"
	settings_window.title = "Settings"
	settings_window.unresizable = false
	settings_window.min_size = Vector2(600, 400)
	add_child(settings_window)

	popup.id_pressed.connect(_on_id_pressed)
