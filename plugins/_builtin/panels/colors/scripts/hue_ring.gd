extends TextureRect

@onready var hcursor := %HueCursor
@onready var color_square := %ColorSquare

var hue := 0.0
var updating := false
var debounce := false

func update_cursor_size() -> void:
	var new_size := size.x
	var ring_width := (new_size / 9)
	hcursor.size.y = ring_width + 4
	hcursor.offset_transform_position.y = -((new_size / 2.0) - (ring_width / 2.0) + 1.0)

func update_cursor_pos() -> void:
	# TODO: get current color from state manager
	var pos: Vector2 = get_local_mouse_position()
	var center := (size / 2.0)
	var radians = atan2(pos.y - center.y, pos.x - center.x)
	var angle := rad_to_deg(radians) + 90.0
	if (angle) < 0: angle += 360.0
	hcursor.rotation_degrees = angle
	color_square.material.set_shader_parameter("current_hue", angle / 360.0)
	hue = angle
	update_color()

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
		var pos: Vector2 = get_local_mouse_position()
		var center := (size / 2.0)
		var ring_width := (size.x / 9)
		var max_dist := (size.x / 2)
		var min_dist := (max_dist - ring_width)
		var dist = center.distance_to(pos)
		# ensures the actual ring was clicked on
		if (dist > max_dist || dist < min_dist): return
		
		updating = true
		update_cursor_pos()

func update_color() -> void:
	var satval = color_square.value
	var new_color = Color.from_hsv(
		hue / 360.0, 
		satval.x, 
		satval.y, 
		StateManager.primary_color.a
	)
	debounce = true
	StateManager.set_primary_color(new_color)

func on_color_changed() -> void:
	if debounce: 
		debounce = false
		return
	var new_hue = StateManager.primary_color.h
	hcursor.rotation_degrees = new_hue * 360.0
	color_square.material.set_shader_parameter("current_hue", new_hue)

func _ready() -> void:
	update_cursor_size()
	on_color_changed()
	resized.connect(update_cursor_size)
	color_square.value_updated.connect(update_color)
	StateManager.primary_color_changed.connect(on_color_changed)
