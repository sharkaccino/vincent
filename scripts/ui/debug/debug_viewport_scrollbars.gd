extends Button

@onready var viewport: ScrollContainer = get_node("../EditorViewport")

func _pressed() -> void:
	var active_project = StateManager.get_active_project()
	var canvas_size = active_project.size * active_project.viewport.zoom
	var canvas_size_rotated = Utils.get_bounding_box_size(canvas_size, active_project.viewport.rotate)
	
	var h_bar = viewport.get_h_scroll_bar()
	var v_bar = viewport.get_v_scroll_bar()
	
	var target_x = viewport.get_size().x + canvas_size_rotated.x - h_bar.size.y
	var target_y = viewport.get_size().y + canvas_size_rotated.y - v_bar.size.x
	
	print("[DEBUG] current max X: ", h_bar.max_value, " current max Y: ", v_bar.max_value)
	print("[DEBUG] target max X: ", target_x, " target max Y: ", target_y)
