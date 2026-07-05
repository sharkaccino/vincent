extends Tree

@onready var root_node = %SettingsDialogRoot

const tree_struct = {
	"SETTINGS_TREE_CATEGORY_GENERAL": [
		"SETTINGS_TREE_PAGE_BEHAVIOR",
		"SETTINGS_TREE_PAGE_LANGUAGE",
		"SETTINGS_TREE_PAGE_PLUGINS"
	],
	"SETTINGS_TREE_CATEGORY_DISPLAY": [
		"SETTINGS_TREE_PAGE_INTERFACE",
		"SETTINGS_TREE_PAGE_VIEWPORT",
		"SETTINGS_TREE_PAGE_THEMES"
	],
	"SETTINGS_TREE_CATEGORY_INPUT": [
		"SETTINGS_TREE_PAGE_PEN",
		"SETTINGS_TREE_PAGE_KEYMAP"
	],
	"SETTINGS_TREE_CATEGORY_ADVANCED": [
		"SETTINGS_TREE_PAGE_DEBUG",
		"SETTINGS_TREE_PAGE_EXPERIMENTAL"
	]
}

var current_category = 0
var current_page = 0

var settings_container: MarginContainer
var default_selected = false

func iterate(value: Variant, parent: TreeItem) -> void:
	if typeof(value) == TYPE_DICTIONARY:
		for key in value.keys():
			var subcategory = create_item(parent)
			subcategory.set_text(0, key)
			subcategory.set_selectable(0, false)
			iterate(value[key], subcategory)
	if typeof(value) == TYPE_STRING:
		var entry = create_item(parent)
		entry.set_text(0, value)
		if default_selected == false:
			set_selected(entry, 0)
			default_selected = true
	elif typeof(value) == TYPE_ARRAY:
		for key in value:
			iterate(key, parent)
	else:
		push_warning("Unknown settings tree item type: ", type_string(typeof(value)))

func build_tree() -> void:
	var root = create_item()
	
	for key in tree_struct.keys():
		var category = create_item(root)
		category.set_text(0, key)
		category.set_selectable(0, false)
		iterate(tree_struct[key], category)

func on_item_select() -> void:
	var category_index = get_selected().get_parent().get_index()
	var page_index = get_selected().get_index()
	
	for node in settings_container.get_children():
		if node.has_meta("category_index") == false: continue
		if node.has_meta("page_index") == false: continue
		
		if node.get_meta("category_index") != category_index: 
			node.visible = false
			continue
		if node.get_meta("page_index") != page_index: 
			node.visible = false
			continue
		
		node.visible = true
	
	current_category = category_index
	current_page = page_index

func _ready() -> void:
	await root_node.ready
	settings_container = %SettingsContainer/MarginContainer
	
	for node in settings_container.get_children():
		node.visible = false
		
	item_selected.connect(on_item_select)
	build_tree()
