extends PanelContainer

@onready var label = $ScrollContainer/MarginContainer/RichTextLabel

func _ready() -> void:
	visible = false
	
	var reader = FileAccess.open("res://LICENSE", FileAccess.READ)
	var license_text = reader.get_as_text()
	reader.close()
	
	label.text = license_text
