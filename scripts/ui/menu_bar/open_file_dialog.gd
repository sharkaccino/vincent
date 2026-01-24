extends FileDialog

func on_files_selected(files) -> void:
	print(files)
	for file: String in files:
		StateManager.load_project_file(file)

func _ready() -> void:
	files_selected.connect(on_files_selected)
