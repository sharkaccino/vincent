extends MenuButton

# TODO: Image menu options
var stats_window

func _on_id_pressed(id) -> void:
	print("[image] menu button pressed: ", id)
	if (id == 0): stats_window.popup()

func _ready() -> void:
	var popup = get_popup()
	
	stats_window = PopupManager.create("res://scenes/image_stats_dialog.tscn")
	stats_window.name = "StatsDialog"
	stats_window.title = "Image Statistics"
	add_child(stats_window)
	
	popup.id_pressed.connect(_on_id_pressed)
