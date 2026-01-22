extends Button

@onready var spinbox: SpinBox = get_node("../SpinBox")

func _pressed() -> void:
	var active_project = StateManager.get_active_project()
	if (active_project.viewport.zoom == 1 && active_project.viewport.autofit == false):
		StateManager.set_autofit(true)
		spinbox.get_line_edit().text = "Fit"
	else:
		StateManager.set_zoom_level(100)
		StateManager.set_autofit(false)
		spinbox.get_line_edit().text = "100"
		spinbox.apply()

func check_control_activation() -> void:
	var project_opened = StateManager.active_project_id != 0
	disabled = !project_opened

func _ready() -> void:
	check_control_activation()
	StateManager.active_project_changed.connect(check_control_activation)
