extends CheckBox

@onready var width_input = get_node("%WidthInput")
@onready var height_input = get_node("%HeightInput")
@onready var target_ratio_label = get_node("%TargetRatioLabel")
@onready var swap_orientation_button = get_node("%SwapOrientationButton")

var float_cleaner = RegEx.new()

func update_target_ratio() -> void:
	await get_tree().process_frame
	var rounded = snappedf(get_meta("target_ratio"), 0.001)
	var ratio_as_str = str(rounded)
	var ratio_clean = float_cleaner.sub(ratio_as_str, "")
	
	target_ratio_label.text = "Target Ratio: %s:1" % ratio_clean

func on_toggle() -> void:
	if button_pressed:
		var new_ratio = width_input.value / height_input.value
		set_meta("target_ratio", new_ratio)
		update_target_ratio()
		target_ratio_label.visible = true
	else:
		target_ratio_label.visible = false

func _ready() -> void:
	target_ratio_label.visible = false
	float_cleaner.compile("\\.[0]*$")
	pressed.connect(on_toggle)
	swap_orientation_button.pressed.connect(update_target_ratio)
