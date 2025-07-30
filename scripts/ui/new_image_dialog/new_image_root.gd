extends Control

@onready var wrapper = get_child(0)

func update_size() -> void:
	size = wrapper.size

func _ready() -> void:
	update_size()
	wrapper.resized.connect(update_size)
