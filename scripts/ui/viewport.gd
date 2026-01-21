extends ScrollContainer

# TODO: fix scrolling becoming offset when window is repeatedly resized

@onready var margin = get_node("%CanvasMargin")
@onready var canvas_control = get_node("%CanvasTransformControl")

var fix_left = 12
var fix_right = 18
var fix_top = 12
var fix_bottom = 18

func center_scroll_bars() -> void:
	await get_tree().process_frame
	var innerSize = canvas_control.get_size()
	var containerSize = get_size()
	var maxX = max(0, innerSize.x - containerSize.x)
	var maxY = max(0, innerSize.y - containerSize.y)
	
	scroll_horizontal = floor((maxX / 2) + fix_left) 
	scroll_vertical = floor((maxY / 2) + fix_top)

func on_resize() -> void:
	await get_tree().process_frame
		
	var canvasSize = canvas_control.get_size()
	var newDimensions = get_size()
	margin.add_theme_constant_override("margin_left", (newDimensions.x / 2) + canvasSize.x - fix_left)
	margin.add_theme_constant_override("margin_right", (newDimensions.x / 2) + canvasSize.x - fix_right)
	margin.add_theme_constant_override("margin_top", (newDimensions.y / 2) + canvasSize.y - fix_top)
	margin.add_theme_constant_override("margin_bottom", (newDimensions.y / 2) + canvasSize.y - fix_bottom)
	
	var active_project = StateManager.get_active_project()
	if active_project == null:
		return
	
	if active_project.viewport.autocenter:
		center_scroll_bars()
	
func on_active_project_changed() -> void:
	if StateManager.active_project_id == 0:
		margin.visible = false
		return
	else:
		margin.visible = true
	
	var active_project = StateManager.get_active_project()
	canvas_control.custom_minimum_size = active_project.size
	
	await get_tree().process_frame
	
	if active_project.viewport.autocenter:
		center_scroll_bars()
	else:
		await get_tree().process_frame
		scroll_horizontal = active_project.viewport.x
		scroll_vertical = active_project.viewport.y

func on_scrolled() -> void:
	var active_project = StateManager.get_active_project()
	
	if active_project == null:
		return
	
	active_project.viewport.x = scroll_horizontal
	active_project.viewport.y = scroll_vertical
	
	active_project.viewport.autocenter = false

func _ready() -> void:
	margin.visible = false
	get_h_scroll_bar().scrolling.connect(on_scrolled)
	get_v_scroll_bar().scrolling.connect(on_scrolled)
	resized.connect(on_resize)
	StateManager.active_project_changed.connect(on_active_project_changed)

func _on_contents_resized() -> void:
	center_scroll_bars()
