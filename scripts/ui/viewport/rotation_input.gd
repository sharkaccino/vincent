extends SpinBox

func _input(event: InputEvent):
	if (event is InputEventMouseButton and event.is_pressed()):
		var evLocal = make_input_local(event)
		if (Rect2(Vector2(0,0), size).has_point(evLocal.position) == false):
			get_line_edit().release_focus()

func _value_changed(_new_value: float) -> void:
	# TODO: set rotation
	return

func check_control_activation() -> void:
	var project_opened = StateManager.active_project_id != 0
	editable = project_opened
	if (!project_opened): value = 0

func _ready() -> void:
	check_control_activation()
	StateManager.active_project_changed.connect(check_control_activation)
