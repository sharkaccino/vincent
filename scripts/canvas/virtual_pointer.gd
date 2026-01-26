extends Control

func on_pointer_move(pos: Vector2) -> void:
	position = pos

func _ready() -> void:
	StateManager.pointer_move.connect(on_pointer_move)
