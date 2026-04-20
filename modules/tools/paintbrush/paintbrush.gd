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

func _update_canvas() -> void:
	var active_project = StateManager.get_active_project()
	var layer = active_project.active_layer_index
	
	await RenderingServer.frame_post_draw
	
	var viewport_data = workspace.get_texture().get_image()
	var layer_content_data: Image = active_project.layers[layer].image_data
	var img_size = layer_content_data.get_size()
	layer_content_data.blend_rect(
		viewport_data, 
		Rect2i(0, 0, img_size.x, img_size.y), 
		Vector2i(0, 0)
	)
	layer_content_data.generate_mipmaps()
	
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
	
	_update_canvas()
	await frame_rendered
	stamp.queue_free()

func _on_pointer_move(mouse_pos: Vector2) -> void:
	current_mouse_pos = mouse_pos
	var old_stamp_pos = last_stamp_pos
	
	if drawing == false: return
	if ToolManager.active_tool != get_meta("tool_id"): return
	if StateManager.active_project_id == 0: return
	
	var created_stamps = []
	var dist = mouse_pos.distance_to(last_stamp_pos)
	var spacing: Vector2 = template_stamp.size * (spacing_input.value / 100)
	
	#print("dist ", dist)
	
	var progressed = spacing.x
	while progressed < dist:
		var lerp_amount = progressed / dist
		var stamp_pos = old_stamp_pos.lerp(mouse_pos, lerp_amount)
		
		#print("creating stamp at pos ", stamp_pos)
		#print("lerp ", lerp_amount)
		
		var stamp: Panel = template_stamp.duplicate()
		stamp.visible = true
		stamp.position = stamp_pos - (stamp.size / 2)
		
		workspace.add_child(stamp)
		created_stamps.append(stamp)
		last_stamp_pos = stamp_pos
		progressed += spacing.x
	
	_update_canvas()
	await frame_rendered
	for stamp in created_stamps:
		stamp.queue_free()

func _on_pointer_up(_button_index: MouseButton) -> void:
	drawing = false

func _on_active_project_changed() -> void:
	var active_project = StateManager.get_active_project()
	workspace.size = active_project.size
	
func _update_brush_settings(..._any) -> void:
	template_stamp.material.set_shader_parameter("color", color_input.color)
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
