extends FileDialog

func handle_file_selection(files) -> void:
	print(files)
	for file: String in files:
		StateManager.load_project_file(file)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	files_selected.connect(handle_file_selection)
