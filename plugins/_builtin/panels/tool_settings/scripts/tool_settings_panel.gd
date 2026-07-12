extends PanelContainer

func _on_tool_registered(tool: Dictionary) -> void:
	var panel: Control = tool.panel.instantiate()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.set_meta("tool_id", tool.id)
	panel.visible = false
	add_child(panel)

func _on_active_tool_changed(id: String) -> void:
	for child in get_children():
		if child.get_meta("tool_id") == id:
			child.visible = true
		else:
			child.visible = false

func _ready() -> void:
	ToolManager.tool_registered.connect(_on_tool_registered)
	ToolManager.active_tool_changed.connect(_on_active_tool_changed)
