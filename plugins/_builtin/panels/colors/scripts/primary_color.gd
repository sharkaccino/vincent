extends PanelContainer

@onready var main_color_box = %PrimaryColor
@onready var color_tri = %PrimaryColorAlphaTri

func update_color() -> void:
	var new_color = StateManager.primary_color
	main_color_box.modulate = new_color
	color_tri.modulate = Color(
		new_color.r,
		new_color.g,
		new_color.b
	)

func _ready() -> void:
	StateManager.primary_color_changed.connect(update_color)
