extends Node

var projects = []
var active_project_id = 0

var dragging = false
var current_drag_type
var current_drag_data

var active_tool = Enums.ToolType.CURSOR

signal projects_changed
signal project_added
signal project_removed
signal active_project_changed
signal drag_announced
signal active_tool_changed
signal rotation_changed
signal zoom_level_changed
signal autofit_changed
@warning_ignore("unused_signal")
signal pointer_move
@warning_ignore("unused_signal")
signal view_mode_changed
@warning_ignore("unused_signal")
signal canvas_updated
signal canvas_update_request

var blank_project = VincentProject.new(Image.create_empty(1, 1, false, Image.FORMAT_RGBAF))

func get_project_data(target_project_id) -> VincentProject:
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
	
	print(active_project_id)
	
	active_project_changed.emit()

func create_project(project_name: String, base_image: Image) -> void:
	var new_project: VincentProject = VincentProject.new(base_image, project_name)
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
	image.convert(Image.Format.FORMAT_RGBAF)
	create_project(path.get_file(), image)

func get_active_project() -> VincentProject:
	return get_project_data(active_project_id)

func move_project(target_project_id: int, target_position: int) -> void:
	var old_pos
	for i in projects.size():
		var project = projects[i]
		if project.id == target_project_id:
			old_pos = i
			break
	
	if old_pos == target_position:
		print("no difference between target position and original position")
		projects_changed.emit()
		return
			
	if (old_pos == null):
		printerr("invalid target project id: %s" % target_project_id)
	else:
		projects.insert(target_position, projects[old_pos])
		
		for i in projects.size():
			if i == target_position:
				continue
			if projects[i].id == target_project_id:
				projects.remove_at(i)
				break
		
		#if old_pos > target_position:
			#projects.remove_at(old_pos + 1)
		#else:
			#projects.remove_at(maxi(0, old_pos - 1))
	
	projects_changed.emit()

func announce_drag(type: Enums.DragType, data: Variant) -> void:
	assert(not dragging, "drag announced while already dragging")
	current_drag_data = data
	current_drag_type = type
	dragging = true
	drag_announced.emit(type)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		dragging = false

func set_active_tool(type: Enums.ToolType) -> void:
	print("set tool: ", type)
	active_tool = type
	active_tool_changed.emit()

func set_zoom_level(new_value: float) -> void:
	var active_project = get_active_project()
	var clamped = clamp(new_value / 100, 0.05, 32)
	if (active_project.viewport.zoom != clamped):
		active_project.viewport.zoom = clamped
		zoom_level_changed.emit()
		
func set_rotation(degrees: float) -> void:
	var active_project = get_active_project()
	if (active_project.viewport.rotate != degrees):
		active_project.viewport.rotate = degrees
		rotation_changed.emit()

func set_autofit(new_value: bool) -> void:
	var active_project = get_active_project()
	if (active_project.viewport.autofit != new_value):
		if (new_value == true):
			set_zoom_level(100)
		active_project.viewport.autofit = new_value
		autofit_changed.emit()

func request_canvas_update() -> void:
	canvas_update_request.emit()
