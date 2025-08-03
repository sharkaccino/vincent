extends ScrollContainer

@onready var margin = $MarginContainer
@onready var scrollbar = get_h_scroll_bar()
@onready var viewport = get_viewport()

var dragging = false
var is_project_tab = false

var left_drag_triggered = false
var right_drag_triggered = false
var do_scroll = false
var scroll_speed = 0

func scrollbar_visibility_change() -> void:
	if scrollbar.visible:
		margin.add_theme_constant_override("margin_bottom", 4)
	else:
		margin.remove_theme_constant_override("margin_bottom")

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		reset_triggers()
		dragging = false

func _process(delta: float) -> void:
	if do_scroll:
		if left_drag_triggered:
			scrollbar.value = scrollbar.value - ((1024 * scroll_speed) * delta)
		elif right_drag_triggered:
			scrollbar.value = scrollbar.value + ((1024 * scroll_speed) * delta)
		viewport.update_mouse_cursor_state()

func reset_triggers() -> void:
	left_drag_triggered = false
	right_drag_triggered = false
	do_scroll = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and dragging and is_project_tab:
		var rect = get_rect()
		var trigger_size = min(128, rect.size.x / 6)
		var within_w = event.position.x > rect.position.x and event.position.x < rect.end.x
		var within_h = event.position.y > rect.position.y and event.position.y < rect.end.y
		
		var left_trigger = event.position.x < (rect.position.x + trigger_size)
		var right_trigger = event.position.x > (rect.end.x - trigger_size)
		
		if within_w and within_h:
			if left_trigger:
				left_drag_triggered = true
				scroll_speed = 1 - ((event.position.x - rect.position.x) / trigger_size)
				do_scroll = true
			elif right_trigger:
				right_drag_triggered = true
				scroll_speed = 1 - ((rect.end.x - event.position.x) / trigger_size)
				do_scroll = true
			else:
				reset_triggers()
		else:
			reset_triggers()

func on_drag_announce(type: StateManager.DragType) -> void:
	dragging = true
	is_project_tab = type == StateManager.DragType.PROJECT_TAB

func on_scrolled() -> void:
	viewport.update_mouse_cursor_state()

func _ready() -> void:
	StateManager.drag_announced.connect(on_drag_announce)
	scrollbar.visibility_changed.connect(scrollbar_visibility_change)
	scrollbar.scrolling.connect(on_scrolled)
