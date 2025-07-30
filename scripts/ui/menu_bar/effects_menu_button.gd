extends MenuButton

# TODO: Effects menu options

func _ready() -> void:
	var popup = get_popup()
	
	popup.add_item("TODO")
	popup.set_item_disabled(0, true)
