extends HBoxContainer

func _ready() -> void:
	# filtering might be unnecessary, but better safe than sorry
	var children = get_children().filter(func(child): return child.get_class() == "MenuButton")
	
	# set color of icons to match text color in all menus
	for menu_button: MenuButton in children:
		var popup = menu_button.get_popup()
		var total_items = popup.item_count
		var font_color = popup.get_theme_color("font_color")
		for i in range(total_items):
			popup.set_item_icon_modulate(i, font_color)
