extends Panel

@onready var svcursor := %SatValCursor

var updating := false
var debounce := false
var value := Vector2(0.0, 1.0)
signal value_updated

func on_resized() -> void:
	var new_pos = Vector2(0, 0)
	new_pos.x = (size.x * value.x)
	new_pos.y = size.y - (size.y * value.y)
	svcursor.position = new_pos

func update_cursor_pos() -> void:
	var pos := get_local_mouse_position()
	var new_pos = pos.clamp(Vector2(0, 0), size)
	svcursor.position = new_pos
	
	value.x = new_pos.x / size.x
	value.y = 1.0 - (new_pos.y / size.y)
	debounce = true
	value_updated.emit()

func _input(event: InputEvent) -> void:
	if (updating == false): return
	if (event is InputEventMouseMotion):
		update_cursor_pos()
	if (event is InputEventMouseButton):
		if (event.button_index == 1 && event.is_released()):
			updating = false

func _gui_input(event: InputEvent) -> void:
	if (event is not InputEventMouseButton): return
	if (event.button_index == 1 && event.is_pressed()): 
		updating = true
		update_cursor_pos()

func on_color_changed() -> void:
	if debounce:
		debounce = false
		return
	
	var new_sat = StateManager.primary_color.s
	var new_val = StateManager.primary_color.v
	
	if (value.y == 0.0 && new_val == 0.0):
		# both new and old colors are completely black,
		# so all we would accomplish here is resetting
		# the saturation, which would be kinda annoying
		return
	
	value.x = new_sat
	value.y = new_val
	
	var new_pos_x = size.x * new_sat
	var new_pos_y = size.y - (size.y * new_val)
	
	svcursor.position = Vector2(new_pos_x, new_pos_y)

func _ready() -> void:
	on_resized()
	on_color_changed()
	resized.connect(on_resized)
	StateManager.primary_color_changed.connect(on_color_changed)
