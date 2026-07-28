extends Panel

@onready var container = %SlidersContainer
@onready var SliderMode = container.SliderMode
@onready var cursor = $SliderCursor

var updating := false
var value := 0.0
signal value_changed

func handle_mouse_input() -> void:
	var pos := get_local_mouse_position()
	var new_pos = pos.clamp(Vector2(0, 0), size)
	cursor.position.x = new_pos.x
	
	value = new_pos.x / size.x
	value_changed.emit()
	
func _input(event: InputEvent) -> void:
	if (updating == false): return
	if (event is InputEventMouseMotion):
		handle_mouse_input()
	if (event is InputEventMouseButton):
		if (event.button_index == 1 && event.is_released()):
			updating = false

func _gui_input(event: InputEvent) -> void:
	if (event is not InputEventMouseButton): return
	if (event.button_index == 1 && event.is_pressed()): 
		updating = true
		handle_mouse_input()

func set_value(new_value: float) -> void:
	if (!is_node_ready()): await ready
	value = clamp(new_value, 0.0, 1.0)
	cursor.position.x = (size.x * new_value)

func on_resized() -> void:
	if (!is_node_ready()): await ready
	cursor.position.x = (size.x * value)

func _ready() -> void:
	resized.connect(on_resized)
