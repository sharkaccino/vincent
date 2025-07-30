extends Button

@onready var width_input = get_node("%WidthInput")
@onready var height_input = get_node("%HeightInput")

func _on_pressed() -> void:
	get_window().hide()
	var width = width_input.value
	var height = height_input.value
	var base_image = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	StateManager.create_project("Untitled Project", base_image)
	
func _ready() -> void:
	pressed.connect(_on_pressed)
	
