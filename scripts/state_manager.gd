extends Node

var projects = []
var active_project_id = 0

signal projects_changed
signal project_added
signal project_removed
signal active_project_changed

var blank_project = Project.new(Image.create_empty(1, 1, false, Image.FORMAT_RGBAF))

func get_project_data(target_project_id) -> Project:
	for i in projects.size():
		var project = projects[i]
		if project.id == target_project_id:
			return project
	return blank_project

func set_active_project(project_id: int) -> void:
	var found = false
	for i in projects.size():
		if projects[i].id == project_id:
			found = true
			break
	
	if found:
		active_project_id = project_id
	else:
		active_project_id = 0
	
	active_project_changed.emit()

func create_project(project_name: String, base_image: Image) -> void:
	var new_project: Project = Project.new(base_image, project_name)
	projects.append(new_project)
	
	set_active_project(new_project.id)
	
	projects_changed.emit()
	project_added.emit(new_project.id)

func remove_project(target_project_id: int) -> void:
	for i in projects.size():
		var project = projects[i]
		if project.id == target_project_id:
			projects.remove_at(i)
			projects_changed.emit()
			project_removed.emit(project.id)
			
			if target_project_id == active_project_id:
				if projects.size() != 0:
					if i == projects.size():
						# switch to previous tab
						set_active_project(projects[i-1].id)
					else:
						# switch to next tab
						set_active_project(projects[i].id)
				else:
					# no other tabs available
					set_active_project(0)
			break

func load_project_file(path: String) -> void:
	# TODO: support custom project files
	var image = Image.load_from_file(path)
	image.generate_mipmaps()
	create_project(path.get_file(), image)

func get_active_project() -> Project:
	return get_project_data(active_project_id)
