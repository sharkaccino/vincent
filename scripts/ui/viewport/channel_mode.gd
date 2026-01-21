extends OptionButton

func _item_selected(_index: int) -> void:
	# TODO: set channel mode
	return

func check_control_activation() -> void:
	var project_opened = StateManager.active_project_id != 0
	disabled = !project_opened
	if (!project_opened): selected = 0

func _ready() -> void:
	check_control_activation()
	StateManager.active_project_changed.connect(check_control_activation)
