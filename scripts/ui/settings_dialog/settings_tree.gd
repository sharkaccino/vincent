extends Tree

# TODO: define page IDs via metadata
# TODO: auto-generate controls for each page
# TODO: move pre-defined tree structure to its own file

#const pages = {
	#"_behavior": 
#}

const tree_struct = {
	"General": [
		"Behavior",
		"Language",
		"Plugins"
	],
	"Display": [
		"Viewport",
		"Themes"
	],
	"Input": [
		"Keymapping"
	],
	"Advanced": [
		"Debug",
		"Experimental"
	]
}

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
	elif typeof(value) == TYPE_ARRAY:
		for key in value:
			iterate(key, parent)
	else:
		push_warning("Unknown settings tree item type: %s" % type_string(typeof(value)))

func build_tree() -> void:
	var root = create_item()
	
	for key in tree_struct.keys():
		var category = create_item(root)
		category.set_text(0, key)
		category.set_selectable(0, false)
		iterate(tree_struct[key], category)

func on_item_select() -> void:
	print(get_selected().get_index())

func _ready() -> void:
	build_tree()
	item_selected.connect(on_item_select)
