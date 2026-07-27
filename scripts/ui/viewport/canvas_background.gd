extends TextureRect

func _ready() -> void:
	texture = CanvasManager.get_alpha_checkerboard()
	stretch_mode = TextureRect.STRETCH_TILE
