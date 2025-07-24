extends MenuButton

func _on_id_pressed(id) -> void:
	print(id)
	if (id == 0): $NewProjectWindow.popup()
	if (id == 1): $OpenFileDialog.visible = true
	# TODO: only use 3rd option when file location is NOT set
	if (id == 3 || id == 4): $SaveFileDialog.visible = true
	if (id == 5): get_tree().quit()

func _ready() -> void:
	var popup = get_popup()
	
	# TODO: populate with recently opened files
	var recentPopup = PopupMenu.new()
	recentPopup.set_name("RecentFilesSubmenu")
	
	popup.set_item_submenu_node(2, recentPopup)
	popup.id_pressed.connect(_on_id_pressed)
