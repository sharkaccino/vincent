extends PanelContainer

@onready var main_color_box = %PrimaryColor
@onready var checkerboard = $Checkerboard

func update_color() -> void:
	var new_color = StateManager.primary_color
	main_color_box.modulate = Color(new_color.r, new_color.g, new_color.b)
	checkerboard.modulate.a = 1.0 - new_color.a

func _ready() -> void:
	update_color()
	StateManager.primary_color_changed.connect(update_color)
