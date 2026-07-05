extends MenuButton

var about_window

func _on_id_pressed(id) -> void:
	if (id == 0): OS.shell_open("https://github.com/sharkaccino/vincent/issues")
	if (id == 1): about_window.popup()

func _ready() -> void:
	var popup = get_popup()
	popup.id_pressed.connect(_on_id_pressed)
	
	about_window = PopupManager.create("res://scenes/about_dialog.tscn")
	about_window.name = "AboutDialog"
	about_window.title = "WINDOW_ABOUT"
	add_child(about_window)
