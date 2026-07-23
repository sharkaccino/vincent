extends Node

var tools = []
var basic_brush_users: Array[String] = []
var active_tool: String
var basic_brush_container: Control
var basic_brush_size: float

signal active_tool_changed
signal tool_registered
signal basic_brush_size_changed

func register(id: String, icon: Texture2D, panel: PackedScene) -> void:
	var data = {
		"id": id,
		"icon": icon,
		"panel": panel
	}
	
	tools.append(data)
	tool_registered.emit(data)

func get_tool_panel(id: String) -> Variant:
	for tool in tools:
		if tool.id == id:
			return tool.panel
	return null

func set_active_tool(id: String) -> void:
	print("set tool: ", id)
	for tool in tools:
		if tool.id == id:
			active_tool = id
			set_brush_cursor_visible(basic_brush_users.has(active_tool))
			active_tool_changed.emit(id)
			break
	
func set_brush_cursor_visible(new_value: bool) -> void:
	basic_brush_container.visible = new_value

func set_brush_cursor_size(new_value: float) -> void:
	basic_brush_size = new_value
	basic_brush_size_changed.emit(new_value)

func add_brush_user(id: String) -> void:
	basic_brush_users.append(id)
