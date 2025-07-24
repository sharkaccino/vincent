extends Window

var scene_template
var popup_contents

func _on_open() -> void:
	PopupManager.dim_main_window()
	
	size = popup_contents.get_size()
	
	# set starting position of popup to center of main window
	var main_window = get_tree().get_root()
	@warning_ignore_start("integer_division")
	position.x = main_window.position.x + (main_window.size.x / 2) - (size.x / 2)
	position.y = main_window.position.y + (main_window.size.y / 2) - (size.y / 2)
	@warning_ignore_restore("integer_division")

func _on_close() -> void:
	hide()
	PopupManager.undim_main_window()
	
	# reset popup contents
	popup_contents.queue_free()
	popup_contents = scene_template.instantiate()
	add_child(popup_contents)

func _ready() -> void:
	var target = get_meta("target_scene")
	if target.length() == 0: return
	
	scene_template = load(target)
	popup_contents = scene_template.instantiate()
	add_child(popup_contents)
	
	about_to_popup.connect(_on_open)
	close_requested.connect(_on_close)
