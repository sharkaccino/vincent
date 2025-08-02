extends ScrollContainer

@onready var margin = $MarginContainer
@onready var scrollbar = get_h_scroll_bar()

func scrollbar_visibility_change() -> void:
	if scrollbar.visible:
		margin.add_theme_constant_override("margin_bottom", 4)
	else:
		margin.remove_theme_constant_override("margin_bottom")

func _ready() -> void:
	scrollbar.visibility_changed.connect(scrollbar_visibility_change)
