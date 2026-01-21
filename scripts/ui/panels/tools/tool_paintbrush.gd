extends Button

func _pressed() -> void:
	StateManager.set_active_tool(Enums.ToolType.PAINTBRUSH)
