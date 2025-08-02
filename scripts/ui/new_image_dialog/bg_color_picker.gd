extends ColorPickerButton

@onready var picker = get_picker()
@onready var alpha_toggle_button = %AlphaChannelToggle
@onready var preview_box = %PreviewBox

var old_alpha = 0

func update_preview(new_color = picker.color) -> void:
	preview_box.self_modulate = new_color

func on_alpha_channel_toggled() -> void:
	var use_alpha = alpha_toggle_button.button_pressed
	
	var r = picker.color.r
	var g = picker.color.g
	var b = picker.color.b
	
	if use_alpha:
		picker.edit_alpha = true
		picker.color = Color(r, g, b, old_alpha)
	else:
		picker.edit_alpha = false
		old_alpha = picker.color.a # save current alpha value in case the user re-enables it
		picker.color = Color(r, g, b, 1)
	update_preview()

func _ready() -> void:
	picker.can_add_swatches = false
	picker.presets_visible = false
	picker.sampler_visible = false
	
	alpha_toggle_button.pressed.connect(on_alpha_channel_toggled)
	picker.color_changed.connect(update_preview)
	update_preview()
