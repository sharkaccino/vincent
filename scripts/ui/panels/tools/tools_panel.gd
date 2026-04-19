extends PanelContainer

@onready var tool_tray = %ToolTray
@onready var tool_button_template: Button = %ToolButtonTemplate

func _on_tool_registered(tool: Dictionary) -> void:
	var tool_button = tool_button_template.duplicate()
	tool_button.name = tool.id
	tool_button.unique_name_in_owner = false
	tool_button.icon = tool.icon
	tool_button.set_meta("tool_id", tool.id)
	tool_button.visible = true
	
	tool_tray.add_child(tool_button)

func _ready() -> void:
	ToolManager.tool_registered.connect(_on_tool_registered)
