extends HBoxContainer

@onready var tab_template = $ProjectTabTemplate
@onready var spacer_template = $ProjectTabSpacerTemplate

func _notification(what: int) -> void:
	for child in get_children():
		if child.get_class() == "Button":
			if child == tab_template:
				continue
			match what:
				NOTIFICATION_DRAG_BEGIN:
					# disables all inputs
					child.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])
				NOTIFICATION_DRAG_END:
					# re-enables all inputs
					# TODO: might be better to put this logic in individual scripts
					child.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_PASS])
					child.mouse_filter = Control.MOUSE_FILTER_STOP
					var close_button = child.find_child("CloseProjectButton", true, false)
					close_button.mouse_filter = Control.MOUSE_FILTER_STOP

func updateTabs() -> void:
	for old_child in get_children():
		if old_child != tab_template and old_child != spacer_template:
			old_child.queue_free()
			
	var start_spacer = spacer_template.duplicate()
	start_spacer.name = "ProjectTabSpacer"
	start_spacer.visible = true
	add_child(start_spacer)
	
	for i in StateManager.projects.size():
		var new_tab_data = StateManager.projects[i]
		var new_tab = tab_template.duplicate()
		new_tab.name = "ProjectTab"
		new_tab.set_meta("project_id", new_tab_data.id)
		new_tab.visible = true
		
		var new_spacer = spacer_template.duplicate()
		new_spacer.name = "ProjectTabSpacer"
		new_spacer.visible = true
		
		if (i+1) == StateManager.projects.size():
			new_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		add_child(new_tab)
		add_child(new_spacer)
	
	print("tab list updated")

func _ready() -> void:
	StateManager.projects_changed.connect(updateTabs)
	
	tab_template.visible = false
	spacer_template.visible = false
