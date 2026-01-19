extends MarginContainer

func update_tree_size_limit() -> void:
	var window_width = get_window().size.x
	var new_size = window_width - 250
	custom_minimum_size.x = new_size

func _ready() -> void:
	update_tree_size_limit()
	get_parent().resized.connect(update_tree_size_limit)
