extends Node

const effects_dir = "res://plugins/_builtin/effects"
const filetypes_dir = "res://plugins/_builtin/filetypes"
const tools_dir = "res://plugins/_builtin/tools"
const plugin_dev_dir = "res://plugins"
const user_plugins_dir = "user://plugins"

const id_regex = "^[a-z0-9-_]+:[a-z0-9-_]+$"

const reserved_namespaces = [
	"builtin",
	"internal",
	"default",
	"standard",
	"vincent"
]

var registered_plugins = []

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
		printerr("Missing metadata property \"compatibility\" for plugin \"", metadata.id, "\"")
		return Error.ERR_INVALID_DATA
	elif typeof(metadata.compatibility) != TYPE_ARRAY || metadata.compatibility.all(is_number) == false:
		printerr("Invalid metadata property \"compatibility\" for plugin \"", metadata.id, "\"")
		return Error.ERR_INVALID_DATA
	
	if "name" in metadata && typeof(metadata.name) != TYPE_STRING:
		printerr("Invalid metadata property \"name\" for plugin \"", metadata.id, "\"")
		return Error.ERR_INVALID_DATA
	
	if "version" in metadata && typeof(metadata.version) != TYPE_STRING:
		printerr("Invalid metadata property \"version\" for plugin \"", metadata.id, "\"")
		return Error.ERR_INVALID_DATA
	
	if "description" in metadata && typeof(metadata.description) != TYPE_STRING:
		printerr("Invalid metadata property \"description\" for plugin \"", metadata.id, "\"")
		return Error.ERR_INVALID_DATA
		
	if "url" in metadata && typeof(metadata.url) != TYPE_STRING:
		printerr("Invalid metadata property \"url\" for plugin \"", metadata.id, "\"")
		return Error.ERR_INVALID_DATA
	
	if "categories" in metadata:
		if typeof(metadata.categories) != TYPE_ARRAY:
			printerr("Invalid metadata property \"categories\" for plugin \"", metadata.id, "\"")
			return Error.ERR_INVALID_DATA
		else:
			for i in range(metadata.categories.size()):
				if typeof(metadata.categories[i]) != TYPE_STRING:
					printerr("Invalid item at index ", i, " in metadata property \"categories\" for plugin \"", metadata.id, "\"")
					return Error.ERR_INVALID_DATA
	
	return Error.OK

func get_plugin(plugin_id: String) -> Dictionary:
	for plugin in registered_plugins:
		if plugin.metadata.id == plugin_id:
			return plugin
	return {}

func _register_plugin(plugin_path: String) -> void:
	var builtin = false
	if plugin_path.begins_with("res://plugins/_builtin/"):
		builtin = true
	
	plugin_path = plugin_path.trim_suffix("/")
		
	if ConfigManager.get_config().get_value("plugins", "enabled") == false: 
		if builtin == false:
			return
			
	if DirAccess.dir_exists_absolute(plugin_path) == false:
		printerr("Path does not exist: \"", plugin_path ,"\"")
		return
	
	var metadata_path = str(plugin_path, "/metadata.json")
	var init_script_path = str(plugin_path, "/init.gd")
	var metadata_exists = ResourceLoader.exists(metadata_path)
	var init_script_exists = ResourceLoader.exists(init_script_path)
	
	if metadata_exists == false:
		push_warning("Could not register plugin at \"", plugin_path, "\". (missing metadata)")
	elif init_script_exists == false:
		push_warning("Could not register plugin at \"", plugin_path, "\". (missing init script)")
	else:
		var metadata: JSON = load(metadata_path)
		var result = validate_metadata(metadata.data, builtin)
		
		if result == Error.ERR_SKIP:
			push_warning("Could not register plugin at \"", plugin_path, "\". (missing or invalid ID)")
		elif result == Error.ERR_UNAUTHORIZED:
			push_warning("Could not register plugin at \"", plugin_path, "\". (invalid ID: namespace is prohibited)")
		elif result == Error.ERR_INVALID_DATA:
			push_warning("Could not register plugin at \"", plugin_path, "\". (invalid metadata)")
		elif metadata.data.compatibility.has(current_plugin_format) == false:
			push_warning("Could not register plugin at \"", plugin_path, "\". (incompatible with current app version)")
		else:
			if "name" not in metadata.data:
				metadata.data.name = metadata.data.id
				
			registered_plugins.append({
				"path": plugin_path,
				"metadata": metadata.data,
				"builtin": builtin
			})
			
			if builtin:
				_load_plugin(metadata.data.id)

func _load_plugin(plugin_id: String) -> void:
	var found_plugin = get_plugin(plugin_id)
	var script = load(str(found_plugin.path, "/init.gd"))
	var plugin_node = Node.new()
	plugin_node.name = found_plugin.metadata.id
	plugin_node.set_script(script)
	get_tree().root.add_child.call_deferred(plugin_node)
	print("plugin loaded: ", plugin_id)

func _ready() -> void:
	var plugins_dir = ProjectSettings.globalize_path(user_plugins_dir)
	var found_plugins = []
	
	for path in ResourceLoader.list_directory(effects_dir):
		found_plugins.append(str(effects_dir, "/", path))
	
	for path in ResourceLoader.list_directory(filetypes_dir):
		found_plugins.append(str(filetypes_dir, "/", path))
	
	for path in ResourceLoader.list_directory(tools_dir):
		found_plugins.append(str(tools_dir, "/", path))
	
	for path in ResourceLoader.list_directory(plugin_dev_dir):
		if path == "_builtin/": continue
		found_plugins.append(str(plugin_dev_dir, "/", path))
	
	if DirAccess.dir_exists_absolute(plugins_dir):
		if ConfigManager.get_config().get_value("plugins", "enabled") == true:
			for path in DirAccess.get_directories_at(plugins_dir):
				found_plugins.append(str(plugins_dir, "/", path))
	else:
		DirAccess.make_dir_recursive_absolute(plugins_dir)
	
	for plugin_path: String in found_plugins:
		_register_plugin(plugin_path)
		
	print("registered plugins: ", registered_plugins.size())
	
	for registered in registered_plugins:
		if registered.path.begins_with("res://plugins/_builtin/"): continue
		var allow_list = ConfigManager.get_config().get_value("plugins", "allow_list")
		if allow_list.has(registered):
			_load_plugin(registered.metadata.id)
