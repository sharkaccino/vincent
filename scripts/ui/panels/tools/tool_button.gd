extends Button

func _pressed() -> void:
	var tool_id = get_meta("tool_id")
	if get_meta("tool_id") == "": return
	
	if ToolManager.active_tool != tool_id:
		ToolManager.set_active_tool(tool_id)

func _ready() -> void:
	if get_meta("tool_id") == "": 
		visible = false
