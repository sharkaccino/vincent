extends ScrollContainer

@onready var margin = $CanvasMargin

func center_scroll_bars() -> void:
	await get_tree().process_frame
	var innerSize = $CanvasMargin.get_size()
	var containerSize = get_size()
	var maxX = max(0, innerSize.x - containerSize.x)
	var maxY = max(0, innerSize.y - containerSize.y)
	
	scroll_horizontal = floor(maxX / 2)
	scroll_vertical = floor(maxY / 2)

func _on_resize() -> void:
	await get_tree().process_frame
	
	var newDimensions = get_size()
	margin.add_theme_constant_override("margin_left", newDimensions.x / 2)
	margin.add_theme_constant_override("margin_right", newDimensions.x / 2)
	margin.add_theme_constant_override("margin_top", newDimensions.y / 2)
	margin.add_theme_constant_override("margin_bottom", newDimensions.y / 2)
	
	center_scroll_bars()
	
func _on_active_project_changed(_a) -> void:
	center_scroll_bars()

func _ready() -> void:
	resized.connect(_on_resize)
	StateManager.active_project_changed.connect(_on_active_project_changed)

func _on_contents_resized() -> void:
	await get_tree().process_frame
	center_scroll_bars()
