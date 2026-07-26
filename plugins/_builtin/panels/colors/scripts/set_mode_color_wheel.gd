extends Button

@onready var cw_container = %ColorWheelContainer
@onready var cs_container = %SlidersContainer

func _pressed() -> void:
	cw_container.visible = true
	cs_container.visible = false
