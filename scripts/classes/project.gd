class_name VincentProject

static var session_ids := -1
#static var chunk_size: int = ProjectSettings.get_setting("rendering/rendering_device/staging_buffer/texture_download_region_size_px")
static var chunk_size := 256

class ViewportMetadata:
	var autofit: bool = true
	var x: float = 0
	var y: float = 0
	var zoom: float = 1
	var rotate: float = 0

class LayerEffect:
	var custom_name: String
	var id: String
	var enabled: bool = true
	var options: Variant

class Layer:
	var name: String = "New Layer"
	var visible: bool = true
	var locked: bool = false
	var chunks: Array[Image]
	var effects: Array[LayerEffect]
	var _size: Vector2i
	var _chunk_count: Vector2i
	
	func _init(project_size: Vector2i):
		_size = project_size
		_chunk_count = Vector2i(
			ceili(float(_size.x) / VincentProject.chunk_size),
			ceili(float(_size.y) / VincentProject.chunk_size)
		)
	
	func set_image(data: Image) -> Error:
		if (data.get_format() != Image.FORMAT_RGBA16):
			data.convert(Image.FORMAT_RGBA16)
		
		if (data.get_size() != _size):
			return ERR_INVALID_DATA
		
		chunks = []
		
		var r_width = _size.x
		var r_height = _size.y
		
		for y in range(_chunk_count.y):
			r_width = _size.x
			for x in range(_chunk_count.x):
				var chunk_data = data.get_region(Rect2i(
					VincentProject.chunk_size * x,
					VincentProject.chunk_size * y,
					min(VincentProject.chunk_size, r_width),
					min(VincentProject.chunk_size, r_height)
				))
				
				# for debugging
				#chunk_data.fill(Color(randf(), randf(), randf()))
				
				chunks.append(chunk_data)
				r_width -= VincentProject.chunk_size
			r_height -= VincentProject.chunk_size
		return OK
		

var id: int
var name: String
var size: Vector2i
var chunks: Vector2i
var viewport: ViewportMetadata
var layers: Array[Layer]
var active_layer_index: int = 0

func _init(base_image: Image, project_name: String = tr("DEFAULT_PROJECT_NAME")):
	# set id
	id = session_ids + 1
	session_ids += 1
	
	# set name
	name = project_name
	
	# set size
	size = base_image.get_size()
	chunks = Vector2i(
		ceili(float(size.x) / VincentProject.chunk_size),
		ceili(float(size.y) / VincentProject.chunk_size)
	)
	
	# set viewport metadata
	viewport = ViewportMetadata.new()
	
	# set initial layer
	var initial_layer = Layer.new(size)
	initial_layer.set_image(base_image)
	initial_layer.name = tr("DEFAULT_PROJECT_LAYER_NAME")
		
	layers.append(initial_layer)
