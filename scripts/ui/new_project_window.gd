extends Window

var scene = preload("res://scenes/new_image.tscn")

func _on_open() -> void:
	StateManager.dim_main_window()
	
	# set starting position of popup to center of main window
	var main_window = get_tree().get_root()
	position.x = main_window.position.x + (main_window.size.x / 2) - (size.x / 2)
	position.y = main_window.position.y + (main_window.size.y / 2) - (size.y / 2)

func _on_close() -> void:
	hide()
	StateManager.undim_main_window()
	
	# completely empty the contents of the popup
	for child in get_children():
		child.queue_free()
	
	# add brand new instance of contents
	# effectively resets everything, especially inputs
	add_child(scene.instantiate())

func _ready() -> void:
	add_child(scene.instantiate())
	about_to_popup.connect(_on_open)
	close_requested.connect(_on_close)
