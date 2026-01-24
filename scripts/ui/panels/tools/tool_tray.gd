extends HFlowContainer

# this whole script is largely temporary
# tool registration will get a more accessible system later

func register_button(button: Button, tool_type: Enums.ToolType) -> void:
	var on_pressed = func () -> void:
		StateManager.set_active_tool(tool_type)
	
	var on_external_change = func () -> void:
		if (StateManager.active_tool == tool_type):
			button.button_pressed = true
	
	button.pressed.connect(on_pressed)
	StateManager.active_tool_changed.connect(on_external_change)
