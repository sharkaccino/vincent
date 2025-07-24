extends AspectRatioContainer

@onready var width_input = get_node("%WidthInput")
@onready var height_input = get_node("%HeightInput")
@onready var ratio_label = get_node("%AspectRatioLabel")

var float_cleaner = RegEx.new()

func update_ratio() -> void:
	var new_ratio = width_input.value / height_input.value
	var rounded = snappedf(new_ratio, 0.001)
	var ratio_as_str = str(rounded)
	var ratio_clean = float_cleaner.sub(ratio_as_str, "")
	
	ratio_label.text = ratio_clean + ":1"
	ratio = new_ratio

func on_value_changed(_a) -> void:
	update_ratio()

func _ready() -> void:
	float_cleaner.compile("\\.[0]*$")
	update_ratio()
	width_input.value_changed.connect(on_value_changed)
	height_input.value_changed.connect(on_value_changed)
