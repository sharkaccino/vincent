extends Button

var zoom_icon = load("res://resources/icons/panel_tools/zoom.svg")
var zoom_fit_icon = load("res://resources/icons/zoom-scan.svg")
@onready var spinbox: SpinBox = get_node("../SpinBox")

func _pressed() -> void:
	var active_project = StateManager.get_active_project()
	if (active_project.viewport.zoom == 1 && active_project.viewport.autofit == false):
		StateManager.set_autofit(true)
	else:
		StateManager.set_zoom_level(100)
		StateManager.set_autofit(false)

func check_control_activation() -> void:
	var project_opened = StateManager.active_project_id != 0
	disabled = !project_opened
	
func handle_external_change() -> void:
	if (StateManager.active_project_id == 0): return
	var active_project = StateManager.get_active_project()
	if (active_project.viewport.autofit):
		icon = zoom_fit_icon
	else:
		icon = zoom_icon

func handle_project_change() -> void:
	check_control_activation()
	handle_external_change()

func _ready() -> void:
	check_control_activation()
	StateManager.active_project_changed.connect(handle_project_change)
	StateManager.autofit_changed.connect(handle_external_change)
