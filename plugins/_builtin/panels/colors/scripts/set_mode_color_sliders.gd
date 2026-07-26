extends Button

@onready var cw_container = %ColorWheelContainer
@onready var cs_container = %SlidersContainer

func _pressed() -> void:
	cw_container.visible = false
	cs_container.visible = true
