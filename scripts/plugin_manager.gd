extends Node

var effects_dir = ResourceLoader.list_directory("res://modules/effects")
var filetypes_dir = ResourceLoader.list_directory("res://modules/filetypes")
var tools_dir = ResourceLoader.list_directory("res://modules/tools")

var id_regex = RegEx.create_from_string("^[a-z0-9-_]+:[a-z0-9-_]+$")

func validate_metadata(metadata: Dictionary) -> Error:
	if "id" not in metadata:
		# id property does not exist
		return Error.ERR_SKIP
	elif typeof(metadata.id) != TYPE_STRING:
		# id property is not a string
		return Error.ERR_SKIP
	elif id_regex.search(metadata.id) == null:
		# id property does not match required format
		return Error.ERR_SKIP
	
	var is_number = func(item):
		# JSON numbers are parsed as floats
		# https://docs.godotengine.org/en/stable/classes/class_json.html
		return typeof(item) == TYPE_FLOAT
		
	if "compatibility" not in metadata:
		printerr("Missing metadata property \"compatibility\" in plugin \"", metadata.id, "\"")
		return Error.ERR_INVALID_DATA
	elif typeof(metadata.compatibility) != TYPE_ARRAY || metadata.compatibility.all(is_number) == false:
		printerr("Invalid metadata property \"compatibility\" in plugin \"", metadata.id, "\"")
		return Error.ERR_INVALID_DATA
	
	# TODO: name, version, description, url, categories
	
	return Error.OK

func _ready() -> void:
	var builtin_plugins = []
	
	for path in effects_dir:
		builtin_plugins.append(str("res://modules/effects/", path))
	
	for path in filetypes_dir:
		builtin_plugins.append(str("res://modules/filetypes/", path))
	
	for path in tools_dir:
		builtin_plugins.append(str("res://modules/tools/", path))
	
	for plugin_path in builtin_plugins:
		var metadata_path = str(plugin_path, "metadata.json")
		var init_script_path = str(plugin_path, "init.gd")
		var metadata_exists = ResourceLoader.exists(metadata_path)
		var init_script_exists = ResourceLoader.exists(init_script_path)
		
		if !metadata_exists:
			push_warning("Could not load plugin at \"", plugin_path, "\". (missing metadata)")
		elif !init_script_exists:
			push_warning("Could not load plugin at \"", plugin_path, "\". (missing metadata)")
		else:
			var metadata: JSON = load(metadata_path)
			var result = validate_metadata(metadata.data)
			
			if result == Error.ERR_SKIP:
				push_warning("Could not load plugin at \"", plugin_path, "\". (missing or invalid ID)")
			elif result == Error.ERR_INVALID_DATA:
				push_warning("Could not load plugin at \"", plugin_path, "\". (invalid metadata)")
			else:
				var script = load(init_script_path)
				var plugin_node = Node.new()
				plugin_node.set_script(script)
				get_tree().root.add_child.call_deferred(plugin_node)
