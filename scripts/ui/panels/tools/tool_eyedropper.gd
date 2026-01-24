extends Button

@onready var tool_registrar = get_node("%ToolTray")

func _ready() -> void:
	tool_registrar.register_button(self, Enums.ToolType.EYEDROPPER)
