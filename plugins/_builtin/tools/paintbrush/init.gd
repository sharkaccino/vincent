extends Node

var metadata = preload("./metadata.json")
var icon_path = preload("res://resources/icons/panel_tools/brush.svg")
var panel = preload("./panel_paintbrush.tscn")

func _ready() -> void:
	ToolManager.register(metadata.data.id, icon_path, panel)
