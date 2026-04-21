extends Node

const effects_dir = "res://modules/effects"
const filetypes_dir = "res://modules/filetypes"
const tools_dir = "res://modules/tools"
const user_plugins_dir = "user://plugins"

const id_regex = "^[a-z0-9-_]+:[a-z0-9-_]+$"

const reserved_namespaces = [
	"builtin",
	"internal",
	"default",
	"standard",
	"vincent"
]

# JSON numbers are read as floats
const current_plugin_format = 1.0

func validate_metadata(metadata: Dictionary, builtin: bool = false) -> Error:
	if "id" not in metadata:
		# id property does not exist
		return Error.ERR_SKIP
	elif typeof(metadata.id) != TYPE_STRING:
		# id property is not a string
		return Error.ERR_SKIP
	elif RegEx.create_from_string(id_regex).search(metadata.id) == null:
		# id property does not match required format
		return Error.ERR_SKIP
	elif builtin == false:
		var tool_namespace = metadata.id.split(":")[0]
		if reserved_namespaces.has(tool_namespace):
			return Error.ERR_UNAUTHORIZED
	
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

func _load_plugin(plugin_path: String) -> void:
	var builtin = false
	if plugin_path.begins_with("res://"):
		builtin = true
	
	if ConfigManager.get_config().plugins.enabled == false: 
		if builtin == false:
			return
	
	if DirAccess.dir_exists_absolute(plugin_path) == false:
		printerr("Path does not exist: \"", plugin_path ,"\"")
		return
	
	if plugin_path.ends_with("/") == false:
		plugin_path = str(plugin_path, "/")
	
	var metadata_path = str(plugin_path, "metadata.json")
	var init_script_path = str(plugin_path, "init.gd")
	var metadata_exists = ResourceLoader.exists(metadata_path)
	var init_script_exists = ResourceLoader.exists(init_script_path)
	
	if metadata_exists == false:
		push_warning("Could not load plugin at \"", plugin_path, "\". (missing metadata)")
	elif init_script_exists == false:
		push_warning("Could not load plugin at \"", plugin_path, "\". (missing init script)")
	else:
		var metadata: JSON = load(metadata_path)
		var result = validate_metadata(metadata.data, builtin)
		
		if result == Error.ERR_SKIP:
			push_warning("Could not load plugin at \"", plugin_path, "\". (missing or invalid ID)")
		elif result == Error.ERR_UNAUTHORIZED:
			push_warning("Could not load plugin at \"", plugin_path, "\". (invalid ID: namespace is prohibited)")
		elif result == Error.ERR_INVALID_DATA:
			push_warning("Could not load plugin at \"", plugin_path, "\". (invalid metadata)")
		elif metadata.data.compatibility.has(current_plugin_format) == false:
			push_warning("Could not load plugin at \"", plugin_path, "\". (incompatible with current app version)")
		else:
			var script = load(init_script_path)
			var plugin_node = Node.new()
			plugin_node.name = metadata.data.id
			plugin_node.set_script(script)
			get_tree().root.add_child.call_deferred(plugin_node)

func _ready() -> void:
	var plugins_dir = ProjectSettings.globalize_path(user_plugins_dir)
	var found_plugins = []
	
	for path in ResourceLoader.list_directory(effects_dir):
		found_plugins.append(str("res://modules/effects/", path))
	
	for path in ResourceLoader.list_directory(filetypes_dir):
		found_plugins.append(str("res://modules/filetypes/", path))
	
	for path in ResourceLoader.list_directory(tools_dir):
		found_plugins.append(str("res://modules/tools/", path))
	
	if DirAccess.dir_exists_absolute(plugins_dir):
		if ConfigManager.get_config().plugins.enabled:
			for path in DirAccess.get_directories_at(plugins_dir):
				found_plugins.append(str(plugins_dir, "/", path))
	else:
		DirAccess.make_dir_recursive_absolute(plugins_dir)
	
	for plugin_path in found_plugins:
		_load_plugin(plugin_path)
