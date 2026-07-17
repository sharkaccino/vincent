extends PanelContainer

@onready var color_input: ColorPickerButton = %TEMPColorInput
@onready var brush_size_input: SpinBox = %BrushSizeInput
@onready var softness_input = %SoftnessInput
@onready var spacing_input = %SpacingInput
@onready var blend_mode_input = %BlendModeInput

var tool_active = false
var drawing = false
var current_mouse_pos: Vector2

var rd = RenderingServer.get_rendering_device()
const brush_shader_file: RDShaderFile = preload("../resources/brush.glsl")
const stamp_pos_shader_file: RDShaderFile = preload("../resources/stamp_pos_writer.glsl")

# MUST match value used in brush.glsl !!
var shader_size = 32
var rd_groups: int

var brush_shader = rd.shader_create_from_spirv(brush_shader_file.get_spirv())
var stamp_shader = rd.shader_create_from_spirv(stamp_pos_shader_file.get_spirv())
var rd_storage_buffer: RID
var rd_stamping_buffer: RID

var affected_chunks: Array[Vector2i] = []

func update_canvas(target_pos: Vector2, target_size: float) -> void:
	var pipeline := rd.compute_pipeline_create(brush_shader)
	
	var project := StateManager.get_active_project()
	var target_chunk := Vector2i(
		floori(target_pos.x / VincentProject.chunk_size),
		floori(target_pos.y / VincentProject.chunk_size)
	)
	var pos_in_chunk := target_pos - Vector2(
		VincentProject.chunk_size * target_chunk.x,
		VincentProject.chunk_size * target_chunk.y
	)
	
	var chunk_idx := (project.chunks.x * target_chunk.y) + target_chunk.x
	
	var input_data := PackedFloat32Array([
		color_input.color.r, 
		color_input.color.g, 
		color_input.color.b, 
		color_input.color.a,
		VincentProject.chunk_size,
		target_chunk.x,
		target_chunk.y,
		pos_in_chunk.x,
		pos_in_chunk.y,
		target_size,
		softness_input.value / 100,
		brush_size_input.value * (spacing_input.value / 100)
	]).to_byte_array()
	
	rd.buffer_update(rd_storage_buffer, 0, input_data.size(), input_data)
	
	var parameter_uniform := RDUniform.new()
	parameter_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	parameter_uniform.binding = 0
	parameter_uniform.add_id(rd_storage_buffer)
	
	var stamping_uniform := RDUniform.new()
	stamping_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	stamping_uniform.binding = 1
	stamping_uniform.add_id(rd_stamping_buffer)
	
	var image_uniform := RDUniform.new()
	image_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	image_uniform.binding = 2
	image_uniform.add_id(CanvasManager.chunks[chunk_idx].texture_rd_rid)
	
	var uniform_set := rd.uniform_set_create([
		parameter_uniform,
		stamping_uniform,
		image_uniform
	], brush_shader, 0)
	
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, rd_groups, rd_groups, 1)
	rd.compute_list_end()
	
	var sp_pipeline := rd.compute_pipeline_create(stamp_shader)
	
	var sp_uniform := RDUniform.new()
	sp_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	sp_uniform.binding = 0
	sp_uniform.add_id(rd_stamping_buffer)
	
	var sp_uniform_set := rd.uniform_set_create([
		sp_uniform,
	], stamp_shader, 0)
	
	var sp_compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(sp_compute_list, sp_pipeline)
	rd.compute_list_bind_uniform_set(sp_compute_list, sp_uniform_set, 0)
	rd.compute_list_dispatch(sp_compute_list, 1, 1, 1)
	rd.compute_list_end()
	
	if affected_chunks.has(target_chunk) == false:
		affected_chunks.append(target_chunk)
	
	#print("draw in chunk: ", target_chunk)
	#print("pos in chunk: ", pos_in_chunk)

func on_pointer_down(button_index: MouseButton) -> void:
	if tool_active == false: return
	if StateManager.active_project_id == 0: return
	
	# TODO: track which pointer starts drawing and disallow 
	# other pointer inputs until the first one finishes
	var m1 = button_index == MouseButton.MOUSE_BUTTON_LEFT
	var m2 = button_index == MouseButton.MOUSE_BUTTON_RIGHT
	if m1 == false && m2 == false: return
		
	drawing = true
	
	var target_size = brush_size_input.value # TODO: pen pressure support
	var target_pos = current_mouse_pos
	
	var target_chunk = Vector2i(
		floori(target_pos.x / VincentProject.chunk_size),
		floori(target_pos.y / VincentProject.chunk_size)
	)
	var pos_in_chunk = target_pos - Vector2(
		VincentProject.chunk_size * target_chunk.x,
		VincentProject.chunk_size * target_chunk.y
	)
	
	var input_data = PackedFloat32Array()
	input_data.resize(12)
	input_data.fill(0.0)
	input_data = input_data.to_byte_array()
	
	rd_storage_buffer = rd.storage_buffer_create(input_data.size(), input_data)
	
	var stamping_data = PackedFloat32Array([
		target_chunk.x,
		target_chunk.y,
		pos_in_chunk.x,
		pos_in_chunk.y,
		target_size,
		0.0, # these are all immediately overridden
		0.0, # in the shader program
		0.0,
		0.0,
		0.0
	]).to_byte_array()
	
	rd_stamping_buffer = rd.storage_buffer_create(stamping_data.size(), stamping_data)
	
	update_canvas(target_pos, target_size)

func on_pointer_move(mouse_pos: Vector2) -> void:
	current_mouse_pos = mouse_pos
	
	if tool_active == false: return
	if drawing == false: return
	if StateManager.active_project_id == 0: return
	
	var target_size = brush_size_input.value # TODO: pen pressure support
	
	update_canvas(mouse_pos, target_size)

func on_pointer_up(_button_index: MouseButton) -> void:
	if tool_active == false: return
	if drawing == false: return
	drawing = false
	
	CanvasManager.bake_chunks(affected_chunks)
	affected_chunks.clear()
	rd.free_rid(rd_storage_buffer)
	rd.free_rid(rd_stamping_buffer)

func on_tool_change(tool_id) -> void:
	var project = StateManager.get_active_project()
	if (tool_id != get_meta("tool_id")) || (project.id == 0): 
		drawing = false
		tool_active = false
		return
		
	tool_active = true

func _ready() -> void:
	rd_groups = ceili(float(VincentProject.chunk_size) / shader_size)
	
	var cursor_container = %PaintbrushCursorContainer
	cursor_container.set_meta("tool_id", get_meta("tool_id"))
	remove_child(cursor_container)
	StateManager.add_viewport_overlay(cursor_container)
	cursor_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cursor_container.visible = false
	
	ToolManager.active_tool_changed.connect(on_tool_change)
	StateManager.pointer_move.connect(on_pointer_move)
	StateManager.pointer_down.connect(on_pointer_down)
	StateManager.pointer_up.connect(on_pointer_up)
