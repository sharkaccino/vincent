extends Button

@onready var dialog = $FileDialog

func _pressed() -> void:
	dialog.visible = true
