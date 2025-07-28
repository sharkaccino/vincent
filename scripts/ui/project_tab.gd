extends Button

@onready var project_id = get_meta("project_id")

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if get_viewport().gui_is_drag_successful() == false:
			if name.containsn("template"):
				return
			visible = true

func _get_drag_data(at_position: Vector2) -> int:
	# set up preview node
	# root_center lets the node to appear to be dragged 
	# by its center rather than the top-left
	var root_center = Control.new()
	var preview_node = duplicate()
	preview_node.modulate.a = 0.5
	preview_node.size.x = size.x
	preview_node.size.y = size.y
	
	root_center.add_child(preview_node)
	
	preview_node.position.x = -(size.x / 2)
	preview_node.position.y = -(size.y / 2)
	set_drag_preview(root_center)
	
	visible = false
	
	StateManager.announce_drag(StateManager.DragType.PROJECT_TAB, { "index": get_index() })
	
	return project_id

func on_pressed() -> void:
	if StateManager.active_project_id != project_id:
		StateManager.set_active_project(project_id)

func _ready() -> void:
	var this_project = StateManager.get_project_data(project_id)
	tooltip_text = this_project.name
	pressed.connect(on_pressed)
