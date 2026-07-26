extends LineEdit

func on_text_changed(new_text) -> void:
	var new_color = Color.from_string(new_text, Color(0,0,0,1))
	StateManager.set_primary_color(new_color)

func on_color_changed(force = false) -> void:
	if is_editing() && !force: return
	var new_color = StateManager.primary_color
	text = str("#", new_color.to_html(false).to_upper())

func on_submit(_a) -> void:
	on_color_changed(true)

func _ready() -> void:
	StateManager.primary_color_changed.connect(on_color_changed)
	text_changed.connect(on_text_changed)
	text_submitted.connect(on_submit)
	focus_exited.connect(on_color_changed)
