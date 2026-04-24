extends PanelContainer

func _restart_required() -> void:
	visible = true

func _ready() -> void:
	if ConfigManager.needs_restart: 
		_restart_required()
	else:
		ConfigManager.restart_required.connect(_restart_required)
