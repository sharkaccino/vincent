extends Panel

@onready var virtual_cursor = %PaintbrushCursor

func update_cursor() -> void:
	var local_pos = get_local_mouse_position()
		
	if (Rect2(Vector2(0,0), size).has_point(local_pos) == false): 
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		visible = false
		return
	
	if (Input.get_current_cursor_shape() == CursorShape.CURSOR_ARROW):
		visible = true
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		virtual_cursor.position = local_pos - (virtual_cursor.size / 2)

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		if (event.relative.is_zero_approx()): return
		update_cursor()

func on_tool_change(tool_id) -> void:
	visible = (tool_id == get_meta("tool_id"))

func _ready() -> void:
	print("ready")
	ToolManager.active_tool_changed.connect(on_tool_change)
	StateManager.zoom_level_changed.connect(update_cursor)
