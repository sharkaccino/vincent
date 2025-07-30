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
	
	# for some reason this spews out tons of warnings
	# if you dont ignore "int_as_enum_without_match"
	# *and* cast each accelerator to a Key type.
	# none of this is mentioned in the docs. yay
	
	@warning_ignore_start("int_as_enum_without_match")
	popup.set_item_accelerator(0, (KEY_MASK_CTRL | KEY_N) as Key)
	popup.set_item_accelerator(1, (KEY_MASK_CTRL | KEY_O) as Key)
	popup.set_item_accelerator(3, (KEY_MASK_CTRL | KEY_S) as Key)
	popup.set_item_accelerator(4, (KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S) as Key)
	popup.set_item_accelerator(5, (KEY_MASK_CTRL | KEY_Q) as Key)
	@warning_ignore_restore("int_as_enum_without_match")
	
	new_project_window = PopupManager.create("res://scenes/new_image.tscn")
	new_project_window.name = "NewImageDialog"
	new_project_window.title = "Create Image"
	add_child(new_project_window)
	
	# TODO: populate with recently opened files
	var recentPopup = PopupMenu.new()
	recentPopup.set_name("RecentFilesSubmenu")
	
	popup.set_item_submenu_node(2, recentPopup)
	popup.id_pressed.connect(_on_id_pressed)
