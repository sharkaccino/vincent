extends Button

const wheel_icon = preload("../resources/mode_color_wheel.png")
const slider_icon = preload("res://resources/icons/panel_colors/adjustments-horizontal.svg")

@onready var wheel = %ColorWheelContainer
@onready var sliders = %SlidersContainer
@onready var picker_container = %ColorPickerContainer

var switch = false

func _pressed() -> void:
	wheel.visible = switch
	sliders.visible = !switch
	
	if (switch):
		# color wheel mode
		picker_container.size_flags_vertical = SIZE_EXPAND_FILL
		picker_container.add_theme_constant_override("separation", 8)
		icon = slider_icon
	else:
		# sliders mode
		picker_container.size_flags_vertical = SIZE_FILL
		picker_container.add_theme_constant_override("separation", 4)
		icon = wheel_icon
	
	switch = !switch
func _ready() -> void:
	wheel.visible = true
	sliders.visible = false
