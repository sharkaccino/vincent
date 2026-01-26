extends FileDialog

# TODO: show additional dialog for image options, e.g jpeg compression level

func on_file_selected(path: String) -> void:
	print("write to: ", path)
	var active_project = StateManager.get_active_project()
	var image_data: Image = active_project.layers[0].image_data
	image_data.convert(Image.Format.FORMAT_RGBA8)
	
	match (path.get_extension()):
		"png":
			image_data.save_png(path)
		"jpg", "jpeg":
			image_data.save_jpg(path)
		"webp":
			image_data.save_webp(path)

func _ready() -> void:
	file_selected.connect(on_file_selected)
