extends Control

var canvas_width = 0
var canvas_height = 0
var canvas_zoom = 1.0

var line_color = Color(0, 0, 0, 1)
var line_width = 1

var lines: PackedVector2Array = []

func _draw() -> void:
	if (canvas_zoom < 4.0): return
	if (lines.size() == 0): return
	
	draw_multiline(lines, line_color, line_width, true)

func recalc_lines() -> void:
	if (canvas_zoom < 4.0): return
	lines.clear()
	
	# adjust opacity based on zoom
	line_color = Color(0, 0, 0, 1)
	line_color.a = min(1.0, remap(canvas_zoom, 4.0, 5.0, 0.0, line_color.a))
	
	var rect = get_rect()
	var canvas_pixel_width = rect.size.x / canvas_width
	var canvas_pixel_height = rect.size.y / canvas_height
	
	var visible_rect = StateManager.canvas_visible_rect
	var v_line_start = max(0.0, visible_rect.position.x)
	var v_line_end = min(canvas_width + 1, visible_rect.position.x + visible_rect.size.x)
	var h_line_start = max(0.0, visible_rect.position.y)
	var h_line_end = min(canvas_height + 1, visible_rect.position.y + visible_rect.size.y)
	
	for i in range(v_line_start, v_line_end):
		var pos_x = (canvas_pixel_width * i)
		var start = Vector2(pos_x, 0)
		var end = Vector2(pos_x, rect.size.y)
		lines.append(start)
		lines.append(end)
	
	for i in range(h_line_start, h_line_end):
		var pos_y = (canvas_pixel_height * i)
		var start = Vector2(0, pos_y)
		var end = Vector2(rect.size.x, pos_y)
		lines.append(start)
		lines.append(end)
	
	queue_redraw()

func on_project_changed() -> void:
	var active_project = StateManager.get_active_project()
	canvas_width = active_project.size.x
	canvas_height = active_project.size.y
	recalc_lines()
	
func on_zoom_level_changed() -> void:
	var active_project = StateManager.get_active_project()
	canvas_zoom = active_project.viewport.zoom
	recalc_lines()
	
func _ready() -> void:
	StateManager.active_project_changed.connect(on_project_changed)
	StateManager.zoom_level_changed.connect(on_zoom_level_changed)
	StateManager.canvas_visible_rect_changed.connect(recalc_lines)
