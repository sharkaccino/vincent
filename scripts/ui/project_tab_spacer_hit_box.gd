extends Panel

# TODO: move this script to parent node
# TODO: docs and cleanup
# its 10 am and i havent slept :)))))

@onready var parent: Control = get_parent()

var current_tween
var tab_width = 250+4
var temp_fill = false
var temp_fill_target = 0

func tween_to_width(new_width: float) -> void:
	if current_tween != null:
		current_tween.kill()
		
	var tree = get_tree()
	current_tween = tree.create_tween()
	current_tween.set_trans(Tween.TRANS_EXPO)
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.tween_property(parent, "custom_minimum_size", Vector2(new_width, 0), 0.2)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_END:
			if get_viewport().gui_is_drag_successful() == false:
				if parent.name.containsn("template"):
					return
				mouse_filter = Control.MOUSE_FILTER_IGNORE
				parent.custom_minimum_size.x = 0
				parent.visible = true
				
				if temp_fill:
					parent.get_parent().get_child(temp_fill_target - 1).size_flags_horizontal = Control.SIZE_FILL
			
func on_mouse_leave() -> void:
	if StateManager.dragging and StateManager.current_drag_type == StateManager.DragType.PROJECT_TAB:
		tween_to_width(0)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var is_valid = typeof(data) == TYPE_INT
	if is_valid:
		tween_to_width(tab_width)
	return is_valid

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var target_pos = floor((parent.get_index() - 2) / 2)
	print("move %s" % data, " to %s" % target_pos)
	StateManager.move_project(data, target_pos)

func handle_begin_drag(type: int) -> void:
	if parent.name.containsn("template"):
		return
	if type == StateManager.DragType.PROJECT_TAB:
		var data = StateManager.current_drag_data
		if (data.index + 1) == parent.get_index():
			parent.visible = false
			if parent.size_flags_horizontal == Control.SIZE_EXPAND_FILL:
				temp_fill = true
				temp_fill_target = data.index
				parent.get_parent().get_child(temp_fill_target - 1).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			if (data.index - 1) == parent.get_index():
				parent.custom_minimum_size.x = tab_width
			mouse_filter = Control.MOUSE_FILTER_STOP

func _ready() -> void:
	StateManager.drag_announced.connect(handle_begin_drag)
	mouse_exited.connect(on_mouse_leave)
