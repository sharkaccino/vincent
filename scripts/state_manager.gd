extends Node

var projects = []
var active_project_id = 0
var session_projects = 0

signal projects_changed
signal project_added
signal project_removed
signal active_project_changed

func get_new_project_id() -> int:
	session_projects += 1
	return session_projects

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
	
	assert(found, "Attempted to set active project to non-existant ID: %s (session_projects: %s)" % [project_id, session_projects])
	
	active_project_id = project_id
	active_project_changed.emit(project_id)

func create_project(projectName: String, base_image: Image) -> void:
	var new_project_id = get_new_project_id()
	projects.append({
		"id": new_project_id,
		"name": projectName,
		"canvas_size": base_image.get_size(),
		"test_image_data": base_image,
		"scroll_pos": Vector2(0, 0),
		"autocenter": true,
		"layers": [
			{
				"name": "Layer 1"
			}
		]
	})
	
	set_active_project(new_project_id)
	
	projects_changed.emit()
	project_added.emit(new_project_id)

func remove_project(target_project_id: int) -> void:
	var last_project_id = 0
	for i in projects.size():
		var project = projects[i]
		if project.id == target_project_id:
			projects.remove_at(i)
			projects_changed.emit()
			project_removed.emit(project.id)
			
			if i == projects.size() && last_project_id != 0:
				set_active_project(last_project_id)
			
			break
		last_project_id = project.id

func load_project_file(path: String) -> void:
	# TODO: support custom project files
	var image = Image.load_from_file(path)
	image.generate_mipmaps()
	create_project(path.get_file(), image)
