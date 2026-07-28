extends PanelContainer;

var current_focus: Control

func on_file_drop(files) -> void:
	print(files)
	for file: String in files:
		# TODO: need to put this filter somewhere more globally accessible
		# otherwise we risk file support becoming out of sync between this
		# and nodes like OpenFileDialog, SaveFileDialog, etc
		var filter = ["png", "jpg", "jpeg", "webp"]
		if filter.has(file.get_extension()):
			StateManager.load_project_file(file)

func _input(event: InputEvent):
	if (current_focus == null): return
	
	if (event is InputEventMouseButton and event.is_pressed()):
		var local = current_focus.make_input_local(event)
		if (Rect2(Vector2(0,0), current_focus.size).has_point(local.position) == false):
			if (current_focus is SpinBox):
				current_focus.get_line_edit().release_focus()
			else:
				current_focus.release_focus()
			current_focus = null

func on_focus_change(node) -> void:
	if (node is SpinBox || node is LineEdit):
		current_focus = node

func _ready():
	DisplayServer.window_set_min_size(Vector2i(600, 400));
	get_window().files_dropped.connect(on_file_drop)
	get_window().gui_focus_changed.connect(on_focus_change)
