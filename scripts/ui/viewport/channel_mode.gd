extends OptionButton

func handle_item_selection(index: int) -> void:
	print("item selected")
	StateManager.view_mode_changed.emit(index)

func check_control_activation() -> void:
	var project_opened = StateManager.active_project_id != 0
	disabled = !project_opened
	if (!project_opened): selected = 0

func _ready() -> void:
	item_selected.connect(handle_item_selection)
	check_control_activation()
	StateManager.active_project_changed.connect(check_control_activation)
