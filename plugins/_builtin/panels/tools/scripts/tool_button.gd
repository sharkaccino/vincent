extends Button

func check_state() -> void:
	disabled = (StateManager.active_project_id == 0)

func _pressed() -> void:
	var tool_id = get_meta("tool_id")
	if get_meta("tool_id") == "": return
	
	if ToolManager.active_tool != tool_id:
		ToolManager.set_active_tool(tool_id)

func _ready() -> void:
	visible = (get_meta("tool_id") != "")
	
	check_state()
	StateManager.active_project_changed.connect(check_state)
