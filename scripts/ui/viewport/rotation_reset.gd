extends Button

func _pressed() -> void:
	StateManager.set_rotation(0)

func check_control_activation() -> void:
	var project_opened = StateManager.active_project_id != 0
	disabled = !project_opened

func _ready() -> void:
	check_control_activation()
	StateManager.active_project_changed.connect(check_control_activation)
