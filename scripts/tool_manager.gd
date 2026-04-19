extends Node

var tools = []
var active_tool

signal active_tool_changed
signal tool_registered

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
			active_tool_changed.emit(id)
			break
	
