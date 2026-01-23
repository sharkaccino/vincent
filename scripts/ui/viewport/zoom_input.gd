extends SpinBox

func _input(event: InputEvent):
	if (event is InputEventMouseButton and event.is_pressed()):
		var evLocal = make_input_local(event)
		if (Rect2(Vector2(0,0), size).has_point(evLocal.position) == false):
			get_line_edit().release_focus()

func handle_value_change(new_value: float) -> void:
	var active_project = StateManager.get_active_project()
	if (new_value == active_project.viewport.zoom * 100): return
	StateManager.set_autofit(false)
	StateManager.set_zoom_level(new_value)
	
func handle_external_change() -> void:
	if (StateManager.active_project_id == 0): return
	var active_project = StateManager.get_active_project()
	var line_edit = get_line_edit()
	
	value = active_project.viewport.zoom * 100
	
	if (active_project.viewport.autofit):
		line_edit.set_deferred("text", "Fit")
	elif (line_edit.text == "Fit"):
		apply()

func check_control_activation() -> void:
	var project_opened = StateManager.active_project_id != 0
	editable = project_opened
	if (!project_opened):
		# doing this instead of value = 100 in case 
		# autofit was previously enabled
		get_line_edit().text = "100"
		apply()

func handle_project_change() -> void:
	check_control_activation()
	handle_external_change()

func _ready() -> void:
	check_control_activation()
	value_changed.connect(handle_value_change)
	StateManager.active_project_changed.connect(handle_project_change)
	StateManager.zoom_level_changed.connect(handle_external_change)
	StateManager.autofit_changed.connect(handle_external_change)
