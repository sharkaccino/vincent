extends SpinBox

@onready var keep_ratio_checkbox = get_node("%KeepAspectRatioCheckbox")
@onready var height_input = get_node("%HeightInput")

func on_value_changed(new_value: float) -> void:
	if keep_ratio_checkbox.button_pressed:
		var target_ratio = keep_ratio_checkbox.get_meta("target_ratio")
		height_input.set_value_no_signal(round(new_value / target_ratio))

func _ready() -> void:
	# from: https://docs.godotengine.org/en/stable/classes/class_image.html
	# TODO: use limit reported by RenderingDevice
	max_value = 16384
	get_line_edit().context_menu_enabled = false
	value_changed.connect(on_value_changed)
