extends Button

@onready var width_input = %WidthInput
@onready var height_input = %HeightInput
@onready var color_input = %BackgroundColorButton
@onready var alpha_checkbox = %AlphaChannelToggle

func _on_pressed() -> void:
	get_window().hide()
	var width = width_input.value
	var height = height_input.value
	var format: Image.Format = Image.FORMAT_RGBAF if alpha_checkbox.button_pressed else Image.FORMAT_RGBF
	var base_image = Image.create_empty(width, height, false, format)

	base_image.fill(color_input.color)
	
	StateManager.create_project("Untitled Project", base_image)
	
func _ready() -> void:
	pressed.connect(_on_pressed)
	
