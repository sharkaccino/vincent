extends Label

@onready var width_input = get_node("%WidthInput")
@onready var height_input = get_node("%HeightInput")
@onready var base_color = self["theme_override_colors/font_color"]

var current_tween
var debounce = false

func flash() -> Tween:
	var tree = get_tree()
	current_tween = tree.create_tween()
	
	self["theme_override_colors/font_color"] = Color(1,1,1,1)
	
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.tween_property(self, "theme_override_colors/font_color", base_color, 0.5)
	
	return current_tween

func on_dimensions_changed(_a) -> void:
	var too_big = width_input.value > 16384 or height_input.value > 16384
	if too_big and visible and debounce:
		return
	
	if too_big:
		visible = true
		debounce = true
		
		await flash().finished
		flash()
	else:
		visible = false
		debounce = false
		if current_tween != null:
			current_tween.kill()
			self["theme_override_colors/font_color"] = base_color

func _ready() -> void:
	visible = false
	width_input.value_changed.connect(on_dimensions_changed)
	height_input.value_changed.connect(on_dimensions_changed)
