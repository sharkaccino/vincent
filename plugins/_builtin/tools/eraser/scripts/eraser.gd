extends PanelContainer

@onready var brush_size_input: SpinBox = %BrushSizeInput
@onready var softness_input = %SoftnessInput
@onready var spacing_input = %SpacingInput
@onready var sharp_toggle = %SharpControl
@onready var shape_input = %ShapeInput

var tool_active = false
var drawing = false
var current_mouse_pos: Vector2

var rd = RenderingServer.get_rendering_device()
const eraser_shader_file: RDShaderFile = preload("../resources/eraser.glsl")

# !! MUST match value used in shader program !!
var shader_size = 32
var rd_groups: int

var brush_shader = rd.shader_create_from_spirv(eraser_shader_file.get_spirv())
var rd_storage_buffer: RID
var rd_stamping_buffer: RID

var affected_chunks: Array[Vector2i] = []

func update_canvas(target_pos: Vector2, target_size: float) -> void:
	var pipeline := rd.compute_pipeline_create(brush_shader)
	
	var last_stamp_data := rd.buffer_get_data(rd_stamping_buffer).to_float32_array()
	var last_stamp := {
		"chunk_x": last_stamp_data[0],
		"chunk_y": last_stamp_data[1],
		"x": last_stamp_data[2],
		"y": last_stamp_data[3],
		"brush_size": last_stamp_data[4],
	}
	
	var point_top_left = Vector2(
		min(
			target_pos.x - (target_size / 2),
			last_stamp.x - (last_stamp.brush_size / 2) + (VincentProject.chunk_size * last_stamp.chunk_x)
		),
		min(
			target_pos.y - (target_size / 2),
			last_stamp.y - (last_stamp.brush_size / 2) + (VincentProject.chunk_size * last_stamp.chunk_y)
		)
	)
	
	var point_bottom_right = Vector2(
		max(
			target_pos.x + (target_size / 2),
			last_stamp.x + (last_stamp.brush_size / 2) + (VincentProject.chunk_size * last_stamp.chunk_x)
		),
		max(
			target_pos.y + (target_size / 2),
			last_stamp.y + (last_stamp.brush_size / 2) + (VincentProject.chunk_size * last_stamp.chunk_y)
		)
	)
	
	var chunk_top_left = Vector2i(
		floori(float(point_top_left.x) / VincentProject.chunk_size),
		floori(float(point_top_left.y) / VincentProject.chunk_size)
	)
	
	var chunk_bottom_right = Vector2i(
		floori(float(point_bottom_right.x) / VincentProject.chunk_size),
		floori(float(point_bottom_right.y) / VincentProject.chunk_size)
	)
	#print(last_stamp)
	#prints(chunk_top_left, chunk_bottom_right)
	
	var project := StateManager.get_active_project()
	var chunk_limit = (project.chunks.x * project.chunks.y) - 1
	var target_chunk := Vector2i(chunk_top_left.x, chunk_top_left.y)
	
	#print(target_chunk)
	
	# i cant believe do...while loops don't exist in gdscript
	while true:
		target_chunk.y = chunk_top_left.y
		while true:
			var pos_in_chunk := target_pos - Vector2(
				VincentProject.chunk_size * target_chunk.x,
				VincentProject.chunk_size * target_chunk.y
			)
			
			var chunk_idx := (project.chunks.x * target_chunk.y) + target_chunk.x
			chunk_idx = clampi(chunk_idx, 0, chunk_limit)
			
			var chunk_oob := 0.0
			if target_chunk.x < 0: chunk_oob = 1.0
			if target_chunk.y < 0: chunk_oob = 1.0
			if target_chunk.x >= project.chunks.x: chunk_oob = 1.0
			if target_chunk.y >= project.chunks.y: chunk_oob = 1.0
			
			var input_data := PackedFloat32Array([
				VincentProject.chunk_size,
				chunk_oob,
				last_stamp.chunk_x,
				last_stamp.chunk_y,
				last_stamp.x,
				last_stamp.y,
				last_stamp.brush_size,
				target_chunk.x,
				target_chunk.y,
				pos_in_chunk.x,
				pos_in_chunk.y,
				target_size,
				1.0 if sharp_toggle.button_pressed else 0.0,
				softness_input.value / 100,
				brush_size_input.value * (spacing_input.value / 100),
				float(shape_input.selected)
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
			
			if (chunk_oob != 1.0) && affected_chunks.has(target_chunk) == false:
				affected_chunks.append(target_chunk)
			
			rd.free_rid(uniform_set)
				
			if target_chunk.y == chunk_bottom_right.y:
				break
			else:
				target_chunk.y += 1
		if target_chunk.x == chunk_bottom_right.x:
			break
		else:
			target_chunk.x += 1
	
	rd.free_rid(pipeline)
	#prints("chunks processed:", _done)

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
	input_data.resize(16)
	input_data.fill(0.0)
	input_data = input_data.to_byte_array()
	
	rd_storage_buffer = rd.storage_buffer_create(input_data.size(), input_data)

	var stamping_data = PackedFloat32Array([
		target_chunk.x,
		target_chunk.y,
		pos_in_chunk.x,
		pos_in_chunk.y,
		target_size
	]).to_byte_array()
	
	rd_stamping_buffer = rd.storage_buffer_create(stamping_data.size(), stamping_data)
	
	update_canvas(target_pos, target_size)
	queue_redraw() # first stamp only appears after moving unless we do this

func on_pointer_move(mouse_pos: Vector2) -> void:
	current_mouse_pos = mouse_pos
	
	if tool_active == false: return;
	if drawing == false: return;
	if StateManager.active_project_id == 0: return;
	
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
	ToolManager.set_brush_cursor_size(brush_size_input.value)

func on_brush_size_change(new_value: float) -> void:
	ToolManager.set_brush_cursor_size(new_value)

func _ready() -> void:
	rd_groups = ceili(float(VincentProject.chunk_size) / shader_size)
	
	ToolManager.add_brush_user(get_meta("tool_id"))
	
	ToolManager.active_tool_changed.connect(on_tool_change)
	StateManager.pointer_move.connect(on_pointer_move)
	StateManager.pointer_down.connect(on_pointer_down)
	StateManager.pointer_up.connect(on_pointer_up)
	brush_size_input.value_changed.connect(on_brush_size_change)
