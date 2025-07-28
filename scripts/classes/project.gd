class_name Project

static var session_ids = -1

class ViewportMetadata:
	var autocenter: bool = true
	var x: float = 0
	var y: float = 0
	var zoom: float = 1

class LayerEffect:
	var custom_name: String
	var id: String
	var options: Variant

class Layer:
	var name: String = "Base Image"
	var visible: bool = true
	var locked: bool = false
	var image_data: Image
	var effects: Array[LayerEffect]

var id: int
var name: String
var size: Vector2i
var viewport: ViewportMetadata
var layers: Array[Layer]

func _init(base_image: Image, project_name: String = "Untitled"):
	# set id
	id = session_ids + 1
	session_ids += 1
	
	# set name
	name = project_name
	
	# set size
	size = base_image.get_size()
	
	# set viewport metadata
	viewport = ViewportMetadata.new()
	
	# set initial layer
	var initial_layer = Layer.new()
	initial_layer.image_data = base_image
	layers.append(initial_layer)
