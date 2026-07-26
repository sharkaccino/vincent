extends PanelContainer

@onready var main_color_box = %SecondaryColor
@onready var color_tri = %SecondaryColorAlphaTri

func update_color() -> void:
	var new_color = StateManager.secondary_color
	main_color_box.modulate = new_color
	color_tri.modulate = Color(
		new_color.r,
		new_color.g,
		new_color.b
	)

func _ready() -> void:
	StateManager.secondary_color_changed.connect(update_color)
