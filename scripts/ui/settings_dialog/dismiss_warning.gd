extends TextureButton

var starting_color = modulate

func _mouse_entered() -> void:
	modulate = Color(1,1,1)
	
func _mouse_exited() -> void:
	modulate = starting_color

func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
