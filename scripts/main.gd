extends Control;

func on_file_drop(files) -> void:
	print(files)
	for file: String in files:
		# TODO: need to put this filter somewhere more globally accessible
		# otherwise we risk file support becoming out of sync between this
		# and nodes like OpenFileDialog, SaveFileDialog, etc
		var filter = ["png", "jpg", "jpeg", "webp"]
		if filter.has(file.get_extension()):
			StateManager.load_project_file(file)

func _ready():
	DisplayServer.window_set_min_size(Vector2i(600, 400));
	get_window().files_dropped.connect(on_file_drop)
