extends HBoxContainer

@onready var template = $ProjectTabTemplate

func updateTabs() -> void:
	for oldTab in get_children():
		if oldTab != template:
			oldTab.queue_free()
	
	for newTabData in StateManager.projects:
		var newTab = template.duplicate()
		newTab.name = "ProjectTab"
		newTab.set_meta("project_id", newTabData.id)
		newTab.visible = true
		
		add_child(newTab)
	
	print("tab list updated")

func _ready() -> void:
	StateManager.projects_changed.connect(updateTabs)
	
	template.visible = false
