extends TextureRect

var grid_size = 12
var color_a = Color(1, 1, 1)
var color_b = Color(0.8, 0.8, 0.8)

func _update_texture() -> void:
	var img = Image.create_empty(grid_size, grid_size, false, Image.FORMAT_RGB8)
	img.fill(color_a)
	@warning_ignore("integer_division")
	var block = grid_size / 2
	img.fill_rect(Rect2i(0, 0, block, block), color_b)
	img.fill_rect(Rect2i(block, block, block, block), color_b)
	
	texture = ImageTexture.create_from_image(img)

func _ready() -> void:
	_update_texture()
