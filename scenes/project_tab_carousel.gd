extends HBoxContainer

@onready var template = $ProjectTabTemplate

func updateTabs() -> void:
	for oldTab in get_children():
		if oldTab != template:
			oldTab.free()
	
	for newTabData in StateManager.projects:
		var newTab = template.duplicate()
		newTab.name = "ProjectTab"
		newTab.get_node("HFlowContainer/VBoxContainer/ProjectName").text = newTabData.name
		newTab.get_node("HFlowContainer/VBoxContainer/ProjectResolution").text = str(newTabData.canvas_size.x) + " x " + str(newTabData.canvas_size.y)
		newTab.visible = true
		
		add_child(newTab)
	
	print("tab list updated")

func _ready() -> void:
	StateManager.projects_changed.connect(updateTabs)
	
	template.visible = false
