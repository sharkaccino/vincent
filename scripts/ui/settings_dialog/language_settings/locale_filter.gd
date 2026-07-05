extends LineEdit

@onready var locale_list = %LocaleList
@onready var no_matches = %NoMatchesLabel

func _input(event: InputEvent):
	if (event is InputEventMouseButton and event.is_pressed()):
		var evLocal = make_input_local(event)
		if (Rect2(Vector2(0,0), size).has_point(evLocal.position) == false):
			release_focus()

func on_text_changed(new_text) -> void:
	var locale_items = locale_list.get_children()
	for item: Button in locale_items:
		var locale_code: String = item.get_meta("Locale")
		if locale_code == "": continue
		
		if new_text == "":
			item.visible = true
			continue
		
		var name_node: Label = item.get_node("./MarginContainer/HBoxContainer/LocaleNameLabel")
		
		if name_node.text.containsn(new_text) or locale_code.containsn(new_text):
			item.visible = true
		else:
			item.visible = false
	
	var some_visible = false
	for item: Button in locale_items:
		if item.visible: some_visible = true
	
	locale_list.visible = some_visible
	no_matches.visible = !some_visible

func _ready() -> void:
	text_changed.connect(on_text_changed)
