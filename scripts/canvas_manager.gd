extends Node

var chunks: Array[Texture2DRD] = []
var rd = RenderingServer.get_rendering_device()
var _overlay_container
var compiler_shader_file = preload("res://resources/chunk_builder.glsl")
var compiler_wg_size = 32
var _compiling = false

signal chunks_rebuilt
signal chunk_update
@warning_ignore("unused_signal")
signal canvas_update
signal _compilation_finish

func add_overlay(node: Node) -> void:
	_overlay_container.add_child(node)

func redraw_chunk(x: int, y: int) -> void:
	var project = StateManager.get_active_project()
	if (project.id == 0): return
	var index = (project.chunks.x * y) + x
	# TODO: compile chunks from all layers
	var chunk: Image = project.layers[0].chunks[index]
	rd.texture_update(chunks[index].texture_rd_rid, 0, chunk.get_data())
	chunk_update.emit(x, y)

func rebuild_chunks() -> void:
	for tex in chunks:
		rd.free_rid(tex.texture_rd_rid)
	
	chunks.clear()
	var project = StateManager.get_active_project()
	if (project.id == 0): 
		chunks_rebuilt.emit()
		return
	
	for y in range(project.chunks.y):
		for x in range(project.chunks.x):
			var index = (project.chunks.x * y) + x
			# TODO: compile chunks from all layers
			var chunk: Image = project.layers[0].chunks[index]
			
			var texture_view := RDTextureView.new()
			var texture_format := RDTextureFormat.new()
			texture_format.width = chunk.get_width()
			texture_format.height = chunk.get_height()
			texture_format.format = RenderingDevice.DATA_FORMAT_R16G16B16A16_UNORM
			texture_format.usage_bits = (
				RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT +
				RenderingDevice.TEXTURE_USAGE_STORAGE_BIT +
				RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT +
				RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
			)
			
			var rd_texture = rd.texture_create(texture_format, texture_view, [chunk.get_data()])
			var t2drd = Texture2DRD.new()
			t2drd.texture_rd_rid = rd_texture
			chunks.append(t2drd)
			
	print("chunk count: ", chunks.size())
	chunks_rebuilt.emit()

func bake_chunks(coord_array: Array[Vector2i]) -> void:
	var project = StateManager.get_active_project()
	if (project.id == 0): return
	
	var finished = 0
	for coord in coord_array:
		var index = (project.chunks.x * coord.y) + coord.x
		
		# FIXME: the async version of this method
		# would be more ideal, but my initial 
		# implementation caused a SIGABRT when
		# too many chunks were selected.
		var data = rd.texture_get_data(chunks[index].texture_rd_rid, 0)
		#print("update chunk at ", index)
		var saved_chunk: Image = project.layers[0].chunks[index]
		saved_chunk.set_data(
			saved_chunk.get_width(),
			saved_chunk.get_height(),
			false,
			Image.FORMAT_RGBA16,
			data
		)
		
		finished += 1
		if (finished == coord_array.size()):
			canvas_update.emit()
	
func _compile_image() -> void:
	var project = StateManager.get_active_project()
	_compiling = true
	var compiler_shader := rd.shader_create_from_spirv(compiler_shader_file.get_spirv())
	var compiler_pipeline := rd.compute_pipeline_create(compiler_shader)
	var wg_size := Vector2i(
		ceili(float(project.size.x) / compiler_wg_size),
		ceili(float(project.size.y) / compiler_wg_size)
	)
	
	var compiled_image := Image.create_empty(
		project.size.x, 
		project.size.y, 
		false, 
		Image.FORMAT_RGBA16
	)
	
	var init_buffer = PackedFloat32Array()
	init_buffer.resize(5)
	init_buffer.fill(0.0)
	init_buffer = init_buffer.to_byte_array()
	
	var rd_data_buffer := rd.storage_buffer_create(init_buffer.size(), init_buffer)
	
	var output_texture_view := RDTextureView.new()
	var output_texture_format := RDTextureFormat.new()
	output_texture_format.width = project.size.x
	output_texture_format.height = project.size.y
	output_texture_format.format = RenderingDevice.DATA_FORMAT_R16G16B16A16_UNORM
	output_texture_format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT +
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT +
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT +
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	)
	
	var output_texture = rd.texture_create(
		output_texture_format,
		output_texture_view,
		[compiled_image.get_data()]
	)
	
	for y in range(project.chunks.y):
		for x in range(project.chunks.x):
			var chunk_tex := chunks[(project.chunks.x * y) + x].texture_rd_rid
			
			var chunk_data := PackedFloat32Array([
				x,
				y,
				VincentProject.chunk_size,
				project.size.x,
				project.size.y
			]).to_byte_array()
			
			rd.buffer_update(rd_data_buffer, 0, chunk_data.size(), chunk_data)
			
			var data_uniform := RDUniform.new()
			data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
			data_uniform.binding = 0
			data_uniform.add_id(rd_data_buffer)
			
			var chunk_uniform := RDUniform.new()
			chunk_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
			chunk_uniform.binding = 1
			chunk_uniform.add_id(chunk_tex)
			
			var output_uniform := RDUniform.new()
			output_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
			output_uniform.binding = 2
			output_uniform.add_id(output_texture)
			
			var uniform_set := rd.uniform_set_create([
				data_uniform,
				chunk_uniform,
				output_uniform
			], compiler_shader, 0)
			
			var compute_list := rd.compute_list_begin()
			rd.compute_list_bind_compute_pipeline(compute_list, compiler_pipeline)
			rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
			rd.compute_list_dispatch(compute_list, wg_size.x, wg_size.y, 1)
			rd.compute_list_end()
			
	var callback = func(data):
		compiled_image.set_data(
			project.size.x,
			project.size.y,
			false,
			Image.FORMAT_RGBA16,
			data
		)
		
		rd.free_rid(compiler_shader)
		rd.free_rid(rd_data_buffer)
		rd.free_rid(output_texture)
		
		_compilation_finish.emit.call_deferred(compiled_image)
		_compiling = false
	
	rd.texture_get_data_async(output_texture, 0, callback)
	
	#var final_texture := rd.texture_get_data(output_texture, 0)

func get_image() -> Image:
	#var project = StateManager.get_active_project()
	#if (project.id == 0):
		#return
	
	if (_compiling == false):
		_compile_image()
		
	# TODO: cache the result of this
	var result = await _compilation_finish
	return result

func _ready() -> void:
	StateManager.active_project_changed.connect(rebuild_chunks)
