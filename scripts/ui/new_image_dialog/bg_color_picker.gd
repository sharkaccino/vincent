extends ColorPickerButton

@onready var picker = get_picker()
@onready var preview_box = %PreviewBox

func update_preview(new_color = picker.color) -> void:
	preview_box.self_modulate = new_color

func _ready() -> void:
	picker.can_add_swatches = false
	picker.presets_visible = false
	picker.sampler_visible = false
	
	picker.color_changed.connect(update_preview)
	update_preview()
