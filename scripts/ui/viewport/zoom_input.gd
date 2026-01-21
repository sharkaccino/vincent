extends SpinBox

func _input(event: InputEvent):
	if (event is InputEventMouseButton and event.is_pressed()):
		var evLocal = make_input_local(event)
		if (Rect2(Vector2(0,0), size).has_point(evLocal.position) == false):
			get_line_edit().release_focus()

func handle_value_change(new_value: float) -> void:
	print("new zoom: ", new_value)
	StateManager.set_zoom_level(new_value)
	
func handle_external_change() -> void:
	var active_project = StateManager.get_active_project()
	set_value_no_signal(active_project.viewport.zoom * 100)

func check_control_activation() -> void:
	var project_opened = StateManager.active_project_id != 0
	editable = project_opened
	if (!project_opened): value = 100

func _ready() -> void:
	check_control_activation()
	value_changed.connect(handle_value_change)
	StateManager.active_project_changed.connect(check_control_activation)
	StateManager.zoom_level_changed.connect(handle_external_change)
