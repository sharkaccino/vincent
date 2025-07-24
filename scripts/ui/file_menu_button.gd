extends MenuButton

var new_project_window

func _on_id_pressed(id) -> void:
	print("[file] menu button pressed: ", id)
	if (id == 0): new_project_window.popup()
	if (id == 1): $OpenFileDialog.visible = true
	# TODO: only use 3rd option when file location is NOT set
	if (id == 3 || id == 4): $SaveFileDialog.visible = true
	if (id == 5): get_tree().quit()

func _ready() -> void:
	var popup = get_popup()
	
	new_project_window = PopupManager.create("res://scenes/new_image.tscn")
	new_project_window.name = "NewImageDialog"
	new_project_window.title = "Create Image"
	add_child(new_project_window)
	
	# TODO: populate with recently opened files
	var recentPopup = PopupMenu.new()
	recentPopup.set_name("RecentFilesSubmenu")
	
	popup.set_item_submenu_node(2, recentPopup)
	popup.id_pressed.connect(_on_id_pressed)
