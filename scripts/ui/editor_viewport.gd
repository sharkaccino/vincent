extends ScrollContainer

@onready var margin = get_node("%CanvasMargin")

var fix_left = 12
var fix_right = 18
var fix_top = 12
var fix_bottom = 18

func center_scroll_bars() -> void:
	await get_tree().process_frame
	var innerSize = margin.get_size()
	var containerSize = get_size()
	var maxX = max(0, innerSize.x - containerSize.x)
	var maxY = max(0, innerSize.y - containerSize.y)
	
	scroll_horizontal = floor((maxX / 2) + fix_left) 
	scroll_vertical = floor((maxY / 2) + fix_top)

func _on_resize() -> void:
	await get_tree().process_frame
	
	var newDimensions = get_size()
	margin.add_theme_constant_override("margin_left", (newDimensions.x / 2) - fix_left)
	margin.add_theme_constant_override("margin_right", (newDimensions.x / 2) - fix_right)
	margin.add_theme_constant_override("margin_top", (newDimensions.y / 2) - fix_top)
	margin.add_theme_constant_override("margin_bottom", (newDimensions.y / 2) - fix_bottom)
	
	center_scroll_bars()
	
func _on_active_project_changed(_a) -> void:
	await get_tree().process_frame
	center_scroll_bars()

func _ready() -> void:
	resized.connect(_on_resize)
	StateManager.active_project_changed.connect(_on_active_project_changed)

func _on_contents_resized() -> void:
	center_scroll_bars()
