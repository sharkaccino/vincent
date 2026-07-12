extends PanelContainer

@onready var rd_output = %PaintbrushRD

@onready var color_input: ColorPickerButton = %TEMPColorInput
@onready var brush_size_input: SpinBox = %BrushSizeInput
@onready var softness_input = %SoftnessInput
@onready var spacing_input = %SpacingInput
@onready var blend_mode_input = %BlendModeInput

var last_stamp_pos: Vector2
var drawing = false
var current_mouse_pos: Vector2

const shader_program: RDShaderFile = preload("../resources/brush.glsl")

var rd = RenderingServer.get_rendering_device()
var rd_texture: RID
var rd_storage_buffer: RID

# MUST match value used in the glsl script
var shader_size = 32
var rd_groups_x: int
var rd_groups_y: int

func is_oob(target_pos: Vector2, target_size: Vector2) -> bool:
	var project = StateManager.get_active_project()
	
	var oob_tests = [
		floor(target_pos.x) > project.size.x,
		floor(target_pos.y) > project.size.y,
		ceil(target_pos.x + target_size.x) < 0,
		ceil(target_pos.y + target_size.y) < 0
	]
	
	return oob_tests.any(func(test): return test)

func _update_canvas(target_pos: Vector2, target_size: Vector2) -> void:
	var shader := rd.shader_create_from_spirv(shader_program.get_spirv())
	var pipeline := rd.compute_pipeline_create(shader)
	
	var input_data = PackedFloat32Array([
		color_input.color.r, 
		color_input.color.g, 
		color_input.color.b, 
		color_input.color.a,
		target_pos.x,
		target_pos.y,
		target_size.x,
		softness_input.value / 100
	]).to_byte_array()
	
	rd.buffer_update(rd_storage_buffer, 0, input_data.size(), input_data)
	
	var parameter_uniform := RDUniform.new()
	parameter_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	parameter_uniform.binding = 0
	parameter_uniform.add_id(rd_storage_buffer)
	
	var image_uniform := RDUniform.new()
	image_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	image_uniform.binding = 1
	image_uniform.add_id(rd_texture)
	
	var uniform_set := rd.uniform_set_create([
		parameter_uniform,
		image_uniform
	], shader, 0)
	
	var compute_list := rd.compute_list_begin()
	
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, rd_groups_x, rd_groups_y, 1)
	rd.compute_list_end()
	
	rd.free_rid(shader)

func _on_pointer_down(button_index: MouseButton) -> void:
	if ToolManager.active_tool != get_meta("tool_id"): return
	if StateManager.active_project_id == 0: return
	
	rd_output.visible = true
	StateManager.canvas.visible = false
	
	var active_project = StateManager.get_active_project()
	var layer_index = active_project.active_layer_index
	var layer: VincentProject.Layer = active_project.layers[layer_index]
	
	var image_f: Image = layer.image
	image_f.clear_mipmaps()
	
	rd_groups_x = ceili(float(active_project.size.x) / shader_size)
	rd_groups_y = ceili(float(active_project.size.y) / shader_size)
	
	var m1 = button_index == MouseButton.MOUSE_BUTTON_LEFT
	var m2 = button_index == MouseButton.MOUSE_BUTTON_RIGHT
	if m1 == false && m2 == false: return
		
	drawing = true
	
	var texture_view := RDTextureView.new()
	var texture_format := RDTextureFormat.new()
	texture_format.width = active_project.size.x
	texture_format.height = active_project.size.y
	texture_format.format = RenderingDevice.DATA_FORMAT_R16G16B16A16_UNORM
	texture_format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT +
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT +
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT +
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	)
	
	rd_texture = rd.texture_create(texture_format, texture_view, [image_f.get_data()])
	
	var t2drd = Texture2DRD.new()
	t2drd.texture_rd_rid = rd_texture
	
	rd_output.texture = t2drd
	
	var target_size = Vector2(brush_size_input.value, brush_size_input.value) # TODO: pen pressure support
	var target_pos = current_mouse_pos - (target_size / 2)
	last_stamp_pos = current_mouse_pos
	
	var input_data = PackedFloat32Array([
		color_input.color.r, 
		color_input.color.g, 
		color_input.color.b, 
		color_input.color.a,
		target_pos.x,
		target_pos.y,
		target_size.x,
		softness_input.value / 100
	]).to_byte_array()
	
	rd_storage_buffer = rd.storage_buffer_create(input_data.size(), input_data)
	
	if is_oob(target_pos, target_size) == false:
		_update_canvas(target_pos, target_size)

func _on_pointer_move(mouse_pos: Vector2) -> void:
	current_mouse_pos = mouse_pos
	var old_stamp_pos = last_stamp_pos
	
	if ToolManager.active_tool != get_meta("tool_id"): return
	
	if drawing == false: return
	if StateManager.active_project_id == 0: return
	
	var dist = mouse_pos.distance_to(last_stamp_pos)
	var spacing = brush_size_input.value * (spacing_input.value / 100)
	
	var progressed = spacing
	while progressed < dist:
		# since cursor position updates are coalesced (at least for now),
		# we need to do some basic interpolation for stamping.
		
		# this is also used to determine whether we should stamp at all
		# depending on the distance from the last successful stamp position
		var lerp_amount = progressed / dist
		var stamp_pos = old_stamp_pos.lerp(mouse_pos, lerp_amount)
		var target_size = Vector2(brush_size_input.value, brush_size_input.value) # TODO: pen pressure support
		var target_pos = stamp_pos - (target_size / 2)
		
		if is_oob(target_pos, target_size):
			last_stamp_pos = stamp_pos
			progressed += spacing
			continue

		_update_canvas(target_pos, target_size)
		last_stamp_pos = stamp_pos
		progressed += spacing

func _on_pointer_up(_button_index: MouseButton) -> void:
	if !drawing: return
	
	var active_project = StateManager.get_active_project()
	var layer_index = active_project.active_layer_index
	var layer: VincentProject.Layer = active_project.layers[layer_index]
	
	drawing = false
	StateManager.canvas.visible = true
	
	var image_data = rd.texture_get_data(rd_texture, 0)
	
	layer.image.set_data(
		active_project.size.x,
		active_project.size.y, 
		false, 
		Image.FORMAT_RGBA16, 
		image_data
	)
	
	layer.image.generate_mipmaps()
	StateManager.canvas_updated.emit()
	
	rd_output.texture = null
	rd.free_rid(rd_texture)
	rd.free_rid(rd_storage_buffer)

func _ready() -> void:
	remove_child(rd_output)
	StateManager.add_canvas_content_node(rd_output)
	rd_output.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var cursor_container = %PaintbrushCursorContainer
	cursor_container.set_meta("tool_id", get_meta("tool_id"))
	remove_child(cursor_container)
	StateManager.add_viewport_overlay(cursor_container)
	cursor_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cursor_container.visible = false
	
	StateManager.pointer_move.connect(_on_pointer_move)
	StateManager.pointer_down.connect(_on_pointer_down)
	StateManager.pointer_up.connect(_on_pointer_up)
