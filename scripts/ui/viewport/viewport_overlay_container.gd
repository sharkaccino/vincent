extends Control

@onready var viewport = %EditorViewport

func on_resize() -> void:
	var vbar: VScrollBar = viewport.get_v_scroll_bar()
	var hbar: HScrollBar = viewport.get_h_scroll_bar()
	custom_maximum_size = viewport.size - Vector2(hbar.size.y, vbar.size.x)

func _ready() -> void:
	viewport.draw.connect(on_resize)
	StateManager.viewport_overlay_container = self
