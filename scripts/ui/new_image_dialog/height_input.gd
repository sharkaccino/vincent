extends SpinBox

@onready var keep_ratio_checkbox = get_node("%KeepAspectRatioCheckbox")
@onready var width_input = get_node("%WidthInput")

func on_value_changed(new_value: float) -> void:
	if keep_ratio_checkbox.button_pressed:
		var target_ratio = keep_ratio_checkbox.get_meta("target_ratio")
		width_input.set_value_no_signal(round(target_ratio * new_value))

func _ready() -> void:
	max_value = Image.MAX_HEIGHT
	get_line_edit().context_menu_enabled = false
	value_changed.connect(on_value_changed)
