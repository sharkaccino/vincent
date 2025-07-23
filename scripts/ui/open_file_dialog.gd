extends FileDialog

func _on_file_selected(path) -> void:
	StateManager.load_project_file(path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	file_selected.connect(_on_file_selected)
