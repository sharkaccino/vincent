extends Node

var chunks: Array[Texture2DRD] = []
var rd = RenderingServer.get_rendering_device()
var _overlay_container

signal chunks_rebuilt
signal chunk_update
@warning_ignore("unused_signal")
signal canvas_update

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
	

func _ready() -> void:
	StateManager.active_project_changed.connect(rebuild_chunks)
