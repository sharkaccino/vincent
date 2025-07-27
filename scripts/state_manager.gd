extends Node

var projects = []
var active_project_id = 0

signal projects_changed
signal project_added
signal project_removed
signal active_project_changed

func get_project_data(target_project_id):
	for i in projects.size():
		var project = projects[i]
		if project.id == target_project_id:
			return project
	return null

func set_active_project(project_id: int) -> void:
	var found = false
	for i in projects.size():
		if projects[i].id == project_id:
			found = true
			break
	
	assert(found, "Attempted to set active project to non-existant ID: %s (Project.session_ids: %s)" % [project_id, Project.session_ids])
	
	active_project_id = project_id
	active_project_changed.emit(project_id)

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
			
			if target_project_id == active_project_id and projects.size() != 0:
				if i == projects.size():
					set_active_project(projects[i-1].id)
				else:
					set_active_project(projects[i].id)
			break

func load_project_file(path: String) -> void:
	# TODO: support custom project files
	var image = Image.load_from_file(path)
	image.generate_mipmaps()
	create_project(path.get_file(), image)
