extends ScrollContainer

@onready var margin: MarginContainer = %CanvasMargin
@onready var canvas_wrapper: Control = %CanvasWrapper
@onready var canvas_control: Control = %CanvasTransformControl

var pan_starting_pos_h = 0
var pan_starting_pos_v = 0
var pan_starting_pos_cursor = Vector2.ZERO
var is_panning = false

# TODO: make this configurable
var autofit_margin = 15

func get_relative_mouse_pos() -> Vector2:
	var active_project = StateManager.get_active_project()
	var real_pos = canvas_control.get_local_mouse_position()
	return real_pos / active_project.viewport.zoom

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
	
	var viewport_size = get_rect().size
	var active_project = StateManager.get_active_project()
	
	if active_project.viewport.autofit:
		var rotated = Utils.get_bounding_box_size(
			active_project.size, 
			deg_to_rad(active_project.viewport.rotate)
		)
		
		var h_ratio = (viewport_size.x - (autofit_margin * 2)) / rotated.x
		var v_ratio = (viewport_size.y - (autofit_margin * 2)) / rotated.y
		active_project.viewport.zoom = min(h_ratio, v_ratio, 1.0)
	
	var canvas_size = active_project.size * active_project.viewport.zoom
	var canvas_size_rotated = Utils.get_bounding_box_size(
		canvas_size, 
		deg_to_rad(active_project.viewport.rotate)
	)
	
	canvas_wrapper.custom_minimum_size = canvas_size_rotated
	canvas_control.custom_minimum_size = canvas_size
	
	canvas_control.rotation_degrees = active_project.viewport.rotate
	canvas_control.pivot_offset = canvas_size / 2
	
	var h_bar = get_h_scroll_bar()
	var v_bar = get_v_scroll_bar()
	
	margin.add_theme_constant_override("margin_left", (viewport_size.x / 2))
	margin.add_theme_constant_override("margin_right", (viewport_size.x / 2) - h_bar.size.y)
	margin.add_theme_constant_override("margin_top", (viewport_size.y / 2))
	margin.add_theme_constant_override("margin_bottom", (viewport_size.y / 2) - v_bar.size.x)
	
	if active_project.viewport.autofit:
		center_scroll_bars()
	else:
		h_bar.set_deferred("value", active_project.viewport.x)
		v_bar.set_deferred("value", active_project.viewport.y)
	
	StateManager.pointer_move.emit(get_relative_mouse_pos())
	
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

func _zoom_level_changed() -> void:
	if is_panning:
		var active_project = StateManager.get_active_project()
		pan_starting_pos_h = active_project.viewport.x
		pan_starting_pos_v = active_project.viewport.y
		pan_starting_pos_cursor = get_local_mouse_position()
		
	recalc_transforms()

var is_button_down = false
	
func _input(event: InputEvent) -> void:
	var is_within_viewport = false
	var localized = make_input_local(event)
	
	if "position" in localized:
		# ignore scrollbar clicks
		var adjusted_rect = get_rect()
		adjusted_rect.size.x -= get_v_scroll_bar().size.x
		adjusted_rect.size.y -= get_h_scroll_bar().size.y
		adjusted_rect = adjusted_rect.abs()
		
		if adjusted_rect.has_point(localized.position): 
			is_within_viewport = true
		
	if (event is InputEventMouseMotion):
		if (event.relative.is_zero_approx()): return
		StateManager.pointer_move.emit(get_relative_mouse_pos())
		
		if (is_panning):
			var active_project = StateManager.get_active_project()
			StateManager.set_autofit(false)
			
			var cursor_diff = localized.position - pan_starting_pos_cursor
			
			active_project.viewport.x = pan_starting_pos_h - cursor_diff.x
			active_project.viewport.y = pan_starting_pos_v - cursor_diff.y
			recalc_transforms()
	if (event is InputEventMouseButton):
		if event.button_index == MouseButton.MOUSE_BUTTON_MIDDLE:
			if event.is_pressed() && is_within_viewport:
				pan_starting_pos_h = scroll_horizontal
				pan_starting_pos_v = scroll_vertical
				pan_starting_pos_cursor = make_input_local(event).position
				is_panning = true
			if event.is_released():
				is_panning = false
		
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			if event.is_released() && is_within_viewport:
				StateManager.set_autofit(false)
				var active_project = StateManager.get_active_project()
				var current_level = active_project.viewport.zoom * 100
				var step = 25
				
				if current_level < 100:
					step = 10
				if current_level < 50:
					step = 5
				if current_level >= 300:
					step = 50
				if current_level >= 500:
					step = 100
				if current_level >= 1000:
					step = 200
				
				var final_level = snapped(current_level + step, step)
				StateManager.set_zoom_level(final_level, canvas_wrapper.get_local_mouse_position())
		
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			if event.is_released() && is_within_viewport:
				StateManager.set_autofit(false)
				var active_project = StateManager.get_active_project()
				var current_level = active_project.viewport.zoom * 100
				var step = 25
				
				if current_level <= 100:
					step = 10
				if current_level <= 50:
					step = 5
				if current_level > 300:
					step = 50
				if current_level > 500:
					step = 100
				if current_level > 1000:
					step = 200
				
				var final_level = snapped(current_level - step, step)
				StateManager.set_zoom_level(final_level, canvas_wrapper.get_local_mouse_position())
				
		var is_m1 = event.button_index == MouseButton.MOUSE_BUTTON_LEFT
		var is_m2 = event.button_index == MouseButton.MOUSE_BUTTON_RIGHT
		if is_m1 || is_m2:
			if event.is_pressed() && is_within_viewport:
				StateManager.pointer_down.emit(event.button_index)
			if event.is_released():
				StateManager.pointer_up.emit(event.button_index)

func _ready() -> void:
	CanvasManager._overlay_container = %CanvasOverlayContainer
	
	margin.visible = false
	
	# TODO: make this configurable
	# this probably lags on slower hardware
	#Input.use_accumulated_input = false
	
	get_h_scroll_bar().scrolling.connect(on_scrolled)
	get_v_scroll_bar().scrolling.connect(on_scrolled)
	
	draw.connect(recalc_transforms)
	StateManager.zoom_level_changed.connect(_zoom_level_changed)
	StateManager.autofit_changed.connect(recalc_transforms)
	StateManager.rotation_changed.connect(recalc_transforms)
	StateManager.canvas_position_changed.connect(recalc_transforms)
	StateManager.active_project_changed.connect(on_active_project_changed)
