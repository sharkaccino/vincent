extends PanelContainer

@onready var template_stamp: Panel = %TemplateStamp
@onready var workspace = $SubViewport

@onready var color_input = %TEMPColorInput
@onready var brush_size_input = %BrushSizeInput
@onready var softness_input = %SoftnessInput
@onready var spacing_input = %SpacingInput
@onready var blend_mode_input = %BlendModeInput

var last_stamp_pos: Vector2
var drawing = false
var current_mouse_pos: Vector2

signal frame_rendered

func _update_canvas(affected_area: Rect2i) -> void:
	var active_project = StateManager.get_active_project()
	var layer = active_project.active_layer_index
	
	await RenderingServer.frame_post_draw
	
	var viewport_data: Image = workspace.get_texture().get_image()
	var layer_content_data: Image = active_project.layers[layer].image_data
	
	var start_x = affected_area.position.x
	var end_x = affected_area.position.x + affected_area.size.x
	var start_y = affected_area.position.y
	var end_y = affected_area.position.y + affected_area.size.y
	
	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			var px = viewport_data.get_pixel(x, y)
			
			if px.a == 0: continue
			var new_color = color_input.color
			new_color.a = px.a
			viewport_data.set_pixel(x, y, new_color)
	
	layer_content_data.blend_rect(
		viewport_data, 
		affected_area, 
		Vector2i(affected_area.position.x, affected_area.position.y)
	)
	
	StateManager.canvas_updated.emit()
	frame_rendered.emit()

func _on_pointer_down(button_index: MouseButton) -> void:
	if ToolManager.active_tool != get_meta("tool_id"): return
	if StateManager.active_project_id == 0: return
	
	var m1 = button_index == MouseButton.MOUSE_BUTTON_LEFT
	var m2 = button_index == MouseButton.MOUSE_BUTTON_RIGHT
	if m1 == false && m2 == false: return
		
	drawing = true
	
	var stamp: Panel = template_stamp.duplicate()
	stamp.visible = true
	stamp.position = current_mouse_pos - (stamp.size / 2)
	
	workspace.add_child(stamp)
	last_stamp_pos = current_mouse_pos
	
	_update_canvas(Rect2i(Vector2i(stamp.position), Vector2i(stamp.size)))
	await frame_rendered
	stamp.queue_free()

func _on_pointer_move(mouse_pos: Vector2) -> void:
	current_mouse_pos = mouse_pos
	var old_stamp_pos = last_stamp_pos
	
	if drawing == false: return
	if ToolManager.active_tool != get_meta("tool_id"): return
	if StateManager.active_project_id == 0: return
	
	var created_stamps = []
	var affected_top
	var affected_left
	var affected_right
	var affected_bottom
	var dist = mouse_pos.distance_to(last_stamp_pos)
	var spacing: Vector2 = template_stamp.size * (spacing_input.value / 100)
	
	var progressed = spacing.x
	var first = true
	while progressed < dist:
		var lerp_amount = progressed / dist
		var stamp_pos = old_stamp_pos.lerp(mouse_pos, lerp_amount)
		var target_size = template_stamp.size # TODO: pen pressure support
		var target_pos = stamp_pos - (target_size / 2)
		
		var oob_left = target_pos.x > workspace.size.x
		var oob_top = target_pos.y > workspace.size.y
		var oob_right = target_pos.x + target_size.x < 0
		var oob_bottom = target_pos.y + target_size.y < 0
		
		if oob_left || oob_top || oob_right || oob_bottom:
			last_stamp_pos = stamp_pos
			progressed += spacing.x
			continue
		
		var stamp: Panel = template_stamp.duplicate()
		stamp.visible = true
		stamp.position = target_pos
		
		if first:
			affected_top = stamp.position.y
			affected_left = stamp.position.x
			affected_right = stamp.position.x + stamp.size.x
			affected_bottom = stamp.position.y + stamp.size.y
			
			first = false
		else:
			affected_top = min(affected_top, stamp.position.y)
			affected_left = min(affected_left, stamp.position.x)
			affected_right = max(affected_right, stamp.position.x + stamp.size.x)
			affected_bottom = max(affected_bottom, stamp.position.y + stamp.size.y)
		
		workspace.add_child(stamp)
		created_stamps.append(stamp)
		last_stamp_pos = stamp_pos
		progressed += spacing.x
	
	if created_stamps.size() == 0: return
	
	var final_rect = Rect2i(
		clamp(affected_left, 0, workspace.size.x),
		clamp(affected_top, 0, workspace.size.y),
		clamp(affected_right - affected_left, 0, workspace.size.x - affected_left + 1),
		clamp(affected_bottom - affected_top, 0, workspace.size.y - affected_top + 1)
	)
	
	#print(final_rect)
	
	_update_canvas(final_rect)
	await frame_rendered
	for stamp in created_stamps:
		stamp.queue_free()

func _on_pointer_up(_button_index: MouseButton) -> void:
	drawing = false

func _on_active_project_changed() -> void:
	var active_project = StateManager.get_active_project()
	workspace.size = active_project.size
	
func _update_brush_settings(..._any) -> void:
	template_stamp.size = Vector2(brush_size_input.value, brush_size_input.value)
	template_stamp.material.set_shader_parameter("size", brush_size_input.value)
	template_stamp.material.set_shader_parameter("softness", softness_input.value / 100)

func _ready() -> void:
	_update_brush_settings()
	
	StateManager.pointer_move.connect(_on_pointer_move)
	StateManager.pointer_down.connect(_on_pointer_down)
	StateManager.pointer_up.connect(_on_pointer_up)
	
	StateManager.active_project_changed.connect(_on_active_project_changed)
	
	color_input.color_changed.connect(_update_brush_settings)
	brush_size_input.value_changed.connect(_update_brush_settings)
	softness_input.value_changed.connect(_update_brush_settings)
	
	#blend_mode_input.item_selected.connect(_update_brush_settings)
