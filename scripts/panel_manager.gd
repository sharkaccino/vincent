extends Node

var _left_column: Node
var _right_column: Node
var _panel_template: Node

class PanelData:
	var id: String
	var title: String
	var node: Node
	var content: Node
	var enabled: bool

var template_registered = false
var l_column_registered = false
var r_column_registered = false
var already_setup = false
var default_return_panel = PanelData.new()

var panel_states = []

signal panel_registered

func register_panel(id: String, title: String, content: PackedScene) -> void:
	var panel = _panel_template.duplicate()
	panel.set_meta("panel_id", id)
	
	var data := PanelData.new()
	data.id = id
	data.title = title
	data.node = panel
	data.content = content.instantiate()
	data.enabled = true # TODO: fetch config data for this value
	
	panel_states.append(data)
	
	# temp
	_left_column.add_child(panel)
	
	panel_registered.emit(data)

func get_panel(id: String) -> PanelData:
	for panel: PanelData in panel_states:
		if (panel.id == id):
			return panel
	return default_return_panel

func setup() -> void:
	if already_setup: return
	
	if template_registered == false: return
	if l_column_registered == false: return
	if r_column_registered == false: return
	
	already_setup = true
	
	print("setting up panels")
	print(panel_states.size())
	
	for data: PanelData in panel_states:
		var panel = _panel_template.duplicate()
		panel.set_meta("panel_id", data.id)
		
		data.node = panel
		
		# temp
		_left_column.add_child(panel)

func set_panel_template(node: Node) -> void:
	_panel_template = node
	template_registered = true
	setup()

func set_left_column(node: Node) -> void:
	_left_column = node
	l_column_registered = true
	setup()

func set_right_column(node: Node) -> void:
	_right_column = node
	r_column_registered = true
	setup()
