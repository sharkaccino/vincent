extends PanelContainer

func _ready() -> void:
	var panel_id = get_meta("panel_id")
	
	if (panel_id == ""):
		PanelManager.set_panel_template(self)
		visible = false
		return
	
	visible = true
	
	var title_node: Label = $VBoxContainer/MarginContainer/HBoxContainer/SidebarPanelTitle
	var content_container: ScrollContainer = $VBoxContainer/SidebarPanelContents
	
	var panel_data := PanelManager.get_panel(panel_id)
	if panel_data.id == "": return
	
	title_node.text = panel_data.title
	content_container.add_child(panel_data.content)
	
	panel_data.content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_data.content.size_flags_vertical = Control.SIZE_EXPAND_FILL
