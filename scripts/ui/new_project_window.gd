extends Window

var scene = preload("res://scenes/new_image.tscn")

func _on_visibility_changed() -> void:
	if visible:
		StateManager.dim_main_window()
	else:
		StateManager.undim_main_window()
		for child in get_children():
			child.queue_free()
		add_child(scene.instantiate())
		
func _on_close_requested() -> void:
	hide()

func _ready() -> void:
	add_child(scene.instantiate())
	visibility_changed.connect(_on_visibility_changed)
	close_requested.connect(_on_close_requested)
