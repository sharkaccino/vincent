extends MenuButton

func _on_id_pressed(id) -> void:
	if (id == 0): OS.shell_open("https://github.com/sharkaccino/vincent")

func _ready() -> void:
	var popup = get_popup()
	popup.id_pressed.connect(_on_id_pressed)
