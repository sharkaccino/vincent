extends Node

var projects = []
var active_project = 0

signal projects_changed
signal project_added
signal project_removed

func create_project(name: String, size: Vector2i, image: Image) -> void:
	projects.append({
		"name": name,
		"canvas_size": size,
		"_image_data": image
	})
	
	projects_changed.emit()
	project_added.emit()

func open_project(path: String) -> void:
	# TODO: support custom project files
	var image = Image.load_from_file(path)
	create_project(path.get_file(), image.get_size(), image)
