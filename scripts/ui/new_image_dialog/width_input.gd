extends SpinBox

@onready var keep_ratio_checkbox = get_node("%KeepAspectRatioCheckbox")
@onready var height_input = get_node("%HeightInput")
@onready var warning_label = get_node("%WarningLabel")

func on_value_changed(new_value: float) -> void:
	if new_value > 16384:
		warning_label.visible = true
		
	if keep_ratio_checkbox.button_pressed:
		var target_ratio = keep_ratio_checkbox.get_meta("target_ratio")
		height_input.set_value_no_signal(round(new_value / target_ratio))

func _ready() -> void:
	max_value = Image.MAX_WIDTH
	get_line_edit().context_menu_enabled = false
	value_changed.connect(on_value_changed)
