extends Button

@onready var width_input = %WidthInput
@onready var height_input = %HeightInput
@onready var color_input = %BackgroundColorButton

func _on_pressed() -> void:
	get_window().hide()
	var width = width_input.value
	var height = height_input.value
	var base_image = Image.create_empty(width, height, false, Image.FORMAT_RGBA16)
	base_image.fill(color_input.color)
	
	StateManager.create_project(tr("DEFAULT_PROJECT_NAME"), base_image)
	
func _ready() -> void:
	pressed.connect(_on_pressed)
	
