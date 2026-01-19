extends Window

var scene_template
var popup_contents: Control

func match_window_size() -> void:
	print("window size matched")
	size = popup_contents.get_size()

func reset_contents() -> void:
	if popup_contents != null:
		popup_contents.queue_free()
	
	popup_contents = scene_template.instantiate()
	add_child(popup_contents)
	
	match_window_size()
	
	if popup_contents.get_meta("resizeable"):
		unresizable = false
		
		# set minimum size based on whichever is larger
		var actual_min = popup_contents.get_minimum_size()
		var custom_min = popup_contents.custom_minimum_size
		
		var min_x = max(actual_min.x, custom_min.x)
		var min_y = max(actual_min.y, custom_min.y)
		
		min_size = Vector2i(min_x, min_y)
		
		# set anchor so resizing actually works
		popup_contents.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		unresizable = true
		popup_contents.resized.connect(match_window_size)

func _on_about_to_popup() -> void:
	PopupManager.dim_main_window()
	
	# set starting position of popup to center of main window
	var main_window = get_tree().get_root()
	@warning_ignore_start("integer_division")
	position.x = main_window.position.x + (main_window.size.x / 2) - (size.x / 2)
	position.y = main_window.position.y + (main_window.size.y / 2) - (size.y / 2)
	@warning_ignore_restore("integer_division")

func close() -> void:
	PopupManager.undim_main_window()
	reset_contents()

func _on_visibility_changed() -> void:
	if not visible:
		close()

func _on_close_requested() -> void:
	hide()

func _ready() -> void:
	var target = get_meta("target_scene")
	if target.length() == 0: return
	
	scene_template = load(target)
	reset_contents()
	
	about_to_popup.connect(_on_about_to_popup)
	visibility_changed.connect(_on_visibility_changed)
	close_requested.connect(_on_close_requested)
