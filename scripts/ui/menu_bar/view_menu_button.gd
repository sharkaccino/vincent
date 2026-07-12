extends MenuButton

# TODO: View menu options

var panelsPopup = PopupMenu.new()

func on_panel_added(new_panel: PanelManager.PanelData) -> void:
	panelsPopup.add_check_item(new_panel.title)

func _ready() -> void:
	panelsPopup.set_name("SidebarPanelsSubmenu")
	
	get_popup().set_item_submenu_node(0, panelsPopup)
	
	PanelManager.panel_registered.connect(on_panel_added)
