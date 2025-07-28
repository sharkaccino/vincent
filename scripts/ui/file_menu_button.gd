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
	
	# shortcut test
	popup.set_item_accelerator(0, KEY_MASK_CTRL | KEY_N)
	popup.set_item_accelerator(1, KEY_MASK_CTRL | KEY_O)
	popup.set_item_accelerator(3, KEY_MASK_CTRL | KEY_S)
	popup.set_item_accelerator(4, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
	popup.set_item_accelerator(5, KEY_MASK_CTRL | KEY_Q)
	
	new_project_window = PopupManager.create("res://scenes/new_image.tscn")
	new_project_window.name = "NewImageDialog"
	new_project_window.title = "Create Image"
	add_child(new_project_window)
	
	# TODO: populate with recently opened files
	var recentPopup = PopupMenu.new()
	recentPopup.set_name("RecentFilesSubmenu")
	
	popup.set_item_submenu_node(2, recentPopup)
	popup.id_pressed.connect(_on_id_pressed)
