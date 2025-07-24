extends Control

func _ready() -> void:
	var root_size = get_tree().current_scene.get_size()
	ProjectSettings.set_setting("display/window/size/viewport_width", root_size.x)
	ProjectSettings.set_setting("display/window/size/viewport_height", root_size.y)
