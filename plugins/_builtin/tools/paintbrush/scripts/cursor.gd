extends Panel

@onready var brush_size_input: SpinBox = %BrushSizeInput
@onready var cursor_ring = %CursorRing
@onready var crosshair = %CursorCrosshair
@onready var ch_large = %CrosshairLarge
@onready var ch_medium = %CrosshairMedium
@onready var ch_small = %CrosshairSmall

func update_cursor_size() -> void:
	var active_project = StateManager.get_active_project()
	var brush_size: float = brush_size_input.value * active_project.viewport.zoom
	brush_size = brush_size + 4.0; # ensures cursor does not become too small to see
	
	ch_large.visible = false
	ch_medium.visible = false
	ch_small.visible = false
	
	if (brush_size > 64):
		ch_large.visible = true
	elif (brush_size > 32):
		ch_medium.visible = true
	elif (brush_size > 16):
		ch_small.visible = true
	
	cursor_ring.size = Vector2(brush_size, brush_size)
	cursor_ring.offset_transform_position = (cursor_ring.size / 2.0) * -1.0
	cursor_ring.material.set_shader_parameter("size", brush_size)

func check_cursor_visibility(pos: Vector2) -> void:
	if visible == false: return
		
	if (Rect2(Vector2(0,0), size).has_point(pos) == false): 
		cursor_ring.visible = false
		crosshair.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED): 
		cursor_ring.visible = false
		crosshair.visible = false
	elif (Input.get_current_cursor_shape() == CursorShape.CURSOR_ARROW):
		cursor_ring.visible = true
		crosshair.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _input(event: InputEvent) -> void:
	var local_pos := get_local_mouse_position()
	if (event is InputEventMouseMotion):
		#if (event.relative.is_zero_approx()): return
		cursor_ring.position = local_pos
		crosshair.position = local_pos.round()
		check_cursor_visibility(local_pos)

func on_tool_change(tool_id) -> void:
	visible = (tool_id == get_meta("tool_id"))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	check_cursor_visibility(get_local_mouse_position())

func _ready() -> void:
	update_cursor_size()
	ToolManager.active_tool_changed.connect(on_tool_change)
	StateManager.zoom_level_changed.connect(update_cursor_size)
	brush_size_input.value_changed.connect(func(_a): update_cursor_size())
