extends Panel

var current_tween
var tween_target = 0

var temp_fill = false
var temp_fill_target = 0

@onready var hitbox: Panel = $ProjectTabSpacerHitBox
@onready var tab_template: Button = get_node("../ProjectTabTemplate")
@onready var carousel: HBoxContainer = get_node("../../ProjectTabCarousel")

@onready var tab_width = tab_template.custom_minimum_size.x
@onready var tab_separation = carousel["theme_override_constants/separation"] * 2
@onready var drop_area_width = tab_width + tab_separation

func _notification(type: int) -> void:
	if type == NOTIFICATION_DRAG_END:
		if get_viewport().gui_is_drag_successful() == false:
			if name.containsn("template"):
				return
			hitbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
			custom_minimum_size.x = 0
			visible = true
			
			if temp_fill:
				carousel.get_child(temp_fill_target - 1).size_flags_horizontal = Control.SIZE_FILL

func tween_to_width(new_width: float) -> void:
	if current_tween != null:
		current_tween.kill()
		
	var tree = get_tree()
	current_tween = tree.create_tween()
	current_tween.set_trans(Tween.TRANS_EXPO)
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.tween_property(self, "custom_minimum_size", Vector2(new_width, 0), 0.2)

func set_tween_target(target: float) -> void:
	# helps prevent tween creation spam
	if tween_target == target:
		return
	tween_target = target
	tween_to_width(target)
	
func expand_spacer() -> void:
	set_tween_target(drop_area_width)

func shrink_spacer() -> void:
	set_tween_target(0)

func on_mouse_leave() -> void:
	if StateManager.dragging and StateManager.current_drag_type == Enums.DragType.PROJECT_TAB:
		set_tween_target(0)

func handle_begin_drag(type: int) -> void:
	if name.containsn("template"):
		return
	if type == Enums.DragType.PROJECT_TAB:
		var data = StateManager.current_drag_data
		var spacer_index = get_index()
		if (data.index + 1) == spacer_index:
			visible = false
			if size_flags_horizontal == Control.SIZE_EXPAND_FILL:
				# the last spacer in the whole carousel is expected to fill the 
				# remaining space. we do this because it allows the user to drop
				# a tab anywhere within the empty space to set it to the last
				# position in the carousel. however, another thing we do when a 
				# drag begins is hide the tab that is currently being dragged 
				# along with the spacer immediately after it. this means 
				# starting a drag with a tab that was already in the last 
				# position would result in that expanding spacer being hidden, 
				# and thus, the empty space would no longer be considered a 
				# valid drop target. this *technically* isn't really a problem, 
				# since moving the last tab to an invalid destination would just
				# put it back to where it was before the drag began, and would
				# effectively be the same result as dropping it in the empty
				# spacer. but valid drop targets are also shown to the user via 
				# the cursor, which means the lack of a valid drop target in the
				# empty space could be confusing. to solve this, all we do is 
				# temporarily make the previous spacer expand in a similar
				# matter until dragging has come to an end
				temp_fill = true
				temp_fill_target = data.index
				var previous_spacer = carousel.get_child(temp_fill_target - 1)
				previous_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			hitbox.mouse_filter = Control.MOUSE_FILTER_STOP
			if (data.index - 1) == spacer_index:
				custom_minimum_size.x = drop_area_width

func _ready() -> void:
	hitbox.mouse_exited.connect(on_mouse_leave)
	StateManager.drag_announced.connect(handle_begin_drag)
