extends HBoxContainer

@onready var softness_input = %SoftnessInput
@onready var softness_label = %SoftnessLabel
@onready var pixel_model_toggle = %PixelModeControl

func on_sharp_mode_toggled(state: bool) -> void:
	if (state == true):
		softness_label.modulate = Color(1,1,1,0.5)
		softness_input.editable = false
	else:
		softness_label.modulate = Color(1,1,1,1)
		softness_input.editable = true

func _ready() -> void:
	on_sharp_mode_toggled(pixel_model_toggle.button_pressed)
	pixel_model_toggle.toggled.connect(on_sharp_mode_toggled)
