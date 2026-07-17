extends Node

var temp_dir: DirAccess

func _ready() -> void:
	temp_dir = DirAccess.create_temp("vincent_edit_history")
	print("temp dir on this system: ", OS.get_temp_dir())
