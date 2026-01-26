extends ScrollContainer

@onready var margin: MarginContainer = %CanvasMargin
@onready var canvas_wrapper: Control = %CanvasWrapper
@onready var canvas_control: Control = %CanvasTransformControl
@onready var virtual_pointer: Control = %VirtualPointer

func update_mouse_pos() -> void:
	var active_project = StateManager.get_active_project()
	var real_pos = canvas_control.get_local_mouse_position()
	var scaled_pos = real_pos / active_project.viewport.zoom
	StateManager.pointer_move.emit(scaled_pos)

func center_scroll_bars() -> void:
	var active_project = StateManager.get_active_project()
	var canvas_size = active_project.size * active_project.viewport.zoom
	var canvas_size_rotated = Utils.get_bounding_box_size(
		canvas_size, 
		deg_to_rad(active_project.viewport.rotate)
	)
	
	var target_x = floor((canvas_size_rotated.x / 2)) 
	var target_y = floor((canvas_size_rotated.y / 2))
	
	var h_bar = get_h_scroll_bar()
	var v_bar = get_v_scroll_bar()
	
	h_bar.set_deferred("value", target_x)
	v_bar.set_deferred("value", target_y)
	
	active_project.viewport.x = target_x
	active_project.viewport.y = target_y

func recalc_transforms() -> void:
	if StateManager.active_project_id == 0:
		return
	
	var active_project = StateManager.get_active_project()
	var canvas_size = active_project.size * active_project.viewport.zoom
	var canvas_size_rotated = Utils.get_bounding_box_size(
		canvas_size, 
		deg_to_rad(active_project.viewport.rotate)
	)
	
	canvas_wrapper.custom_minimum_size = canvas_size
	canvas_control.custom_minimum_size = canvas_size
	
	canvas_control.rotation_degrees = active_project.viewport.rotate
	canvas_control.pivot_offset = canvas_size / 2
	
	var xAdd = canvas_size_rotated.x - canvas_size.x
	var yAdd = canvas_size_rotated.y - canvas_size.y
	
	var h_bar = get_h_scroll_bar()
	var v_bar = get_v_scroll_bar()
	
	margin.add_theme_constant_override("margin_left", (get_size().x / 2) + (xAdd / 2))
	margin.add_theme_constant_override("margin_right", (get_size().x / 2) + (xAdd / 2) - h_bar.size.y)
	margin.add_theme_constant_override("margin_top", (get_size().y / 2) + (yAdd / 2))
	margin.add_theme_constant_override("margin_bottom", (get_size().y / 2) + (yAdd / 2) - v_bar.size.x)
	
	if active_project.viewport.autofit:
		center_scroll_bars()
	else:
		h_bar.set_deferred("value", active_project.viewport.x)
		v_bar.set_deferred("value", active_project.viewport.y)
	
	update_mouse_pos()
	
func on_active_project_changed() -> void:
	if StateManager.active_project_id == 0:
		margin.visible = false
		return
	else:
		margin.visible = true
		recalc_transforms()

func on_scrolled() -> void:
	if StateManager.active_project_id == 0:
		return
	
	var active_project = StateManager.get_active_project()
	
	active_project.viewport.x = scroll_horizontal
	active_project.viewport.y = scroll_vertical
	
	StateManager.set_autofit(false)

func on_resized() -> void:
	print("new viewport size: ", get_size())
	recalc_transforms()

var is_button_down = false

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		if (event.relative.is_zero_approx()): return
		update_mouse_pos()
		if (is_button_down):
			StateManager.request_canvas_update()
	if (event is InputEventMouseButton):
		if (event.is_pressed() && event.button_index == MouseButton.MOUSE_BUTTON_LEFT):
			var evLocal = make_input_local(event)
			if (get_rect().has_point(evLocal.position)):
				is_button_down = true
				StateManager.request_canvas_update()
		if (event.is_released() && event.button_index == MouseButton.MOUSE_BUTTON_LEFT):
			is_button_down = false

func _ready() -> void:
	margin.visible = false
	
	get_h_scroll_bar().scrolling.connect(on_scrolled)
	get_v_scroll_bar().scrolling.connect(on_scrolled)
	
	draw.connect(recalc_transforms)
	StateManager.zoom_level_changed.connect(recalc_transforms)
	StateManager.autofit_changed.connect(recalc_transforms)
	StateManager.rotation_changed.connect(recalc_transforms)
	StateManager.active_project_changed.connect(on_active_project_changed)
