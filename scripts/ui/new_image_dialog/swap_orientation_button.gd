extends Button

@onready var keep_ratio_checkbox = get_node("%KeepAspectRatioCheckbox")
@onready var width_input = get_node("%WidthInput")
@onready var height_input = get_node("%HeightInput")

func check_should_disable(_a) -> void:
	# no point in giving the user this option when it would effectively do nothing
	if width_input.value == height_input.value:
		disabled = true
	else:
		disabled = false

func on_pressed() -> void:
	var new_width = height_input.value
	var new_height = width_input.value
	var new_ratio = 1 / keep_ratio_checkbox.get_meta("target_ratio")
	
	keep_ratio_checkbox.set_meta("target_ratio", new_ratio)
	width_input.value = new_width
	height_input.value = new_height
	
func _ready() -> void:
	pressed.connect(on_pressed)
	width_input.value_changed.connect(check_should_disable)
	height_input.value_changed.connect(check_should_disable)
