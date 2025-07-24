extends Button

@onready var keep_ratio_checkbox = get_node("%KeepAspectRatioCheckbox")
@onready var width_input = get_node("%WidthInput")
@onready var height_input = get_node("%HeightInput")

func _on_pressed() -> void:
	var new_width = height_input.value
	var new_height = width_input.value
	var new_ratio = 1 / keep_ratio_checkbox.get_meta("target_ratio")
	
	keep_ratio_checkbox.set_meta("target_ratio", new_ratio)
	width_input.value = new_width
	height_input.value = new_height
	
func _ready() -> void:
	pressed.connect(_on_pressed)
