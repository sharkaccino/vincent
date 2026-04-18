extends Control

var canvas_width = 0
var canvas_height = 0
var canvas_zoom = 1.0
var canvas_rotate = 0

var line_color = Color(0, 0, 0, 1)
var line_width = 1

func _draw() -> void:
	# TODO: should probably skip lines that aren't visible
	if canvas_zoom < 4.0:
		return
	
	# adjust opacity based on zoom
	var final_color = Color(line_color)
	final_color.a = min(1.0, remap(canvas_zoom, 4.0, 5.0, 0.0, line_color.a))
	
	var rect = get_rect()
	var canvas_pixel_width = rect.size.x / canvas_width
	var canvas_pixel_height = rect.size.y / canvas_height
	
	var lines: PackedVector2Array = []
	
	for i in range(canvas_width):
		if i == 0: continue
		var pos_x = (canvas_pixel_width * i)
		var start = Vector2(pos_x, 0)
		var end = Vector2(pos_x, rect.size.y)
		lines.append(start)
		lines.append(end)
	
	for i in range(canvas_height):
		if i == 0: continue
		var pos_y = (canvas_pixel_height * i)
		var start = Vector2(0, pos_y)
		var end = Vector2(rect.size.x, pos_y)
		lines.append(start)
		lines.append(end)
	
	draw_multiline(lines, final_color, line_width, true)

func _project_changed() -> void:
	var active_project = StateManager.get_active_project()
	canvas_width = active_project.size.x
	canvas_height = active_project.size.y
	
func _zoom_level_changed() -> void:
	var active_project = StateManager.get_active_project()
	canvas_zoom = active_project.viewport.zoom

func _rotation_changed() -> void:
	var active_project = StateManager.get_active_project()
	canvas_rotate = active_project.viewport.rotate
	
func _ready() -> void:
	StateManager.active_project_changed.connect(_project_changed)
	StateManager.zoom_level_changed.connect(_zoom_level_changed)
	StateManager.rotation_changed.connect(_rotation_changed)
