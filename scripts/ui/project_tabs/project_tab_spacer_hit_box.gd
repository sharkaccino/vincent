extends Panel

@onready var parent: Panel = get_parent()

func is_valid() -> bool:
	var dragging = StateManager.dragging
	var is_project_tab = StateManager.current_drag_type == Enums.DragType.PROJECT_TAB
	return dragging and is_project_tab

func _can_drop_data(_a, _d) -> bool:
	var valid = is_valid()
	if valid:
		parent.expand_spacer()
	return valid

func _drop_data(_a, data: Variant) -> void:
	var valid = is_valid()
	if valid:
		# calculate position by subtracting 2 (to ignore template nodes)
		# and then dividing by 2 (every other node is a tab instead of a spacer)
		
		# no need for floor() after division since GDScript basically already 
		# handles it due to index being an int
		@warning_ignore("integer_division")
		var target_pos = (parent.get_index() - 2) / 2
		
		print("move project #%s" % data, " to pos %s" % target_pos)
		StateManager.move_project(data, target_pos)
