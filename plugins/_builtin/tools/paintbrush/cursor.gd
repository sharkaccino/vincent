extends Panel

@onready var cursor_ring = %CursorRing
@onready var crosshair = %CursorCrosshair

func update_cursor() -> void:
	if visible == false: return
	var local_pos := get_local_mouse_position()
		
	if (Rect2(Vector2(0,0), size).has_point(local_pos) == false): 
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		cursor_ring.visible = false
		crosshair.visible = false
		return
	
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED): 
		cursor_ring.visible = false
		crosshair.visible = false
		return
	
	if (Input.get_current_cursor_shape() == CursorShape.CURSOR_ARROW):
		cursor_ring.visible = true
		crosshair.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		cursor_ring.position = local_pos
		crosshair.position = local_pos.round()

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		if (event.relative.is_zero_approx()): return
		update_cursor()

func on_tool_change(tool_id) -> void:
	visible = (tool_id == get_meta("tool_id"))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	update_cursor()

func _ready() -> void:
	print("ready")
	ToolManager.active_tool_changed.connect(on_tool_change)
	StateManager.zoom_level_changed.connect(update_cursor)
