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

const current_plugin_format = 1

func validate_metadata(metadata: ConfigFile, builtin: bool = false) -> Error:
	var is_int = func(item):
		return typeof(item) == TYPE_INT
	
	var plugin_id = get_value_or_null(metadata, "id")
	var plugin_compatibility = get_value_or_null(metadata, "compatibility")
	
	var optional_test_basic = func(property: String) -> bool:
		var val = get_value_or_null(metadata, property)
		if val == null: return false
		
		var result = typeof(val) != TYPE_STRING
		if result:
			printerr("Invalid metadata property \"", property, "\" for plug-in \"", plugin_id, "\"")
			return result
		return result
	
	
	if typeof(plugin_id) != TYPE_STRING:
		# id property is null or not a string
		return Error.ERR_SKIP
	elif RegEx.create_from_string(id_regex).search(plugin_id) == null:
		# id property does not match required format
		return Error.ERR_SKIP
	elif builtin == false:
		var tool_namespace = plugin_id.split(":")[0]
		if reserved_namespaces.has(tool_namespace):
			return Error.ERR_UNAUTHORIZED
		
	if plugin_compatibility == null:
		printerr("Missing metadata property \"compatibility\" for plug-in \"", plugin_id, "\"")
		return Error.ERR_INVALID_DATA
	elif typeof(plugin_compatibility) != TYPE_ARRAY || plugin_compatibility.all(is_int) == false:
		printerr("Invalid metadata property \"compatibility\" for plug-in \"", plugin_id, "\"")
		return Error.ERR_INVALID_DATA
	
	if optional_test_basic.call("name"):
		return Error.ERR_INVALID_DATA
	
	if optional_test_basic.call("version"):
		return Error.ERR_INVALID_DATA
	
	if optional_test_basic.call("description"):
		return Error.ERR_INVALID_DATA
	
	if optional_test_basic.call("url"):
		return Error.ERR_INVALID_DATA
	
	if optional_test_basic.call("icon"):
		return Error.ERR_INVALID_DATA
	
	return Error.OK

func get_plugin(plugin_id: String) -> Dictionary:
	for plugin in registered_plugins:
		if plugin.metadata.get_value("plugin_metadata", "id") == plugin_id:
			return plugin
	return {}

func get_value_or_null(metadata, property) -> Variant:
	var val = metadata.get_value("plugin_metadata", property, "")
	if typeof(val) == TYPE_STRING && val == "": return null
	else: return val

func _register_plugin(plugin_path: String) -> void:
	var builtin = false
	if plugin_path.begins_with("res://plugins/_builtin/"):
		builtin = true
	
	plugin_path = plugin_path.trim_suffix("/")
		
	if ConfigManager.get_value("plugins", "enabled") == false: 
		if builtin == false:
			return
			
	if DirAccess.dir_exists_absolute(plugin_path) == false:
		printerr("Path does not exist: \"", plugin_path ,"\"")
		return
	
	var metadata_path = str(plugin_path, "/metadata.ini")
	var init_script_path = str(plugin_path, "/init.gd")
	var metadata_exists = FileAccess.file_exists(metadata_path)
	var init_script_exists = ResourceLoader.exists(init_script_path)
	
	if metadata_exists == false:
		push_warning("Could not register plug-in at \"", plugin_path, "\". (missing metadata)")
	elif init_script_exists == false:
		push_warning("Could not register plug-in at \"", plugin_path, "\". (missing init script)")
	else:
		var metadata: ConfigFile = ConfigFile.new()
		var load_result = metadata.load(metadata_path)
		
		if load_result != Error.OK:
			push_error("Could not load plug-in at \"", plugin_path, "\". (failed to load ConfigFile: ", error_string(load_result), ")")
			return
		
		var result = validate_metadata(metadata, builtin)
		
		var plugin_id = metadata.get_value("plugin_metadata", "id")
		
		if result == Error.ERR_SKIP:
			push_warning("Could not register plug-in at \"", plugin_path, "\". (missing or invalid ID)")
		elif result == Error.ERR_UNAUTHORIZED:
			push_warning("Could not register plug-in at \"", plugin_path, "\". (invalid ID: namespace is prohibited)")
		elif result == Error.ERR_INVALID_DATA:
			push_warning("Could not register plug-in at \"", plugin_path, "\". (invalid metadata)")
		elif metadata.get_value("plugin_metadata", "compatibility").has(current_plugin_format) == false:
			push_warning("Could not register plug-in at \"", plugin_path, "\". (incompatible with current app version)")
		else:
			for registered in registered_plugins:
				if registered.id == plugin_id:
					push_warning("Could not register plug-in at \"", plugin_path, "\". (id already taken by plugin at \"", registered.path, "\")")
			
			if get_value_or_null(metadata, "name") == null:
				metadata.set_value("plugin_metadata", "name", plugin_id)
				
			registered_plugins.append({
				"id": plugin_id,
				"path": plugin_path,
				"metadata": metadata,
				"builtin": builtin
			})
			
			if builtin:
				_load_plugin(plugin_id)

func _load_plugin(plugin_id: String) -> void:
	var found_plugin = get_plugin(plugin_id)
	if "path" not in found_plugin: return
	
	var script = load(str(found_plugin.path, "/init.gd"))
	var plugin_node = Node.new()
	plugin_node.name = found_plugin.metadata.get_value("plugin_metadata", "id")
	plugin_node.set_meta("path", found_plugin.path)
	plugin_node.set_script(script)
	get_tree().root.add_child.call_deferred(plugin_node)
	print("plug-in loaded: ", plugin_id)

func _ready() -> void:
	var plugins_dir = ProjectSettings.globalize_path(user_plugins_dir)
	var found_plugins = []
	
	for path in ResourceLoader.list_directory(effects_dir):
		found_plugins.append(str(effects_dir, "/", path))
	
	for path in ResourceLoader.list_directory(filetypes_dir):
		found_plugins.append(str(filetypes_dir, "/", path))
	
	for path in ResourceLoader.list_directory(tools_dir):
		found_plugins.append(str(tools_dir, "/", path))
	
	if DirAccess.dir_exists_absolute(plugins_dir):
		if ConfigManager.get_value("plugins", "enabled") == true:
			# get unpacked plugins
			for path in DirAccess.get_directories_at(plugins_dir):
				found_plugins.append(str(plugins_dir, "/", path))
			
			# get packed plugins
			for file in DirAccess.get_files_at(plugins_dir):
				if file.ends_with(".zip") || file.ends_with(".pck"):
					ProjectSettings.load_resource_pack(str(plugins_dir, "/", file), false)
	else:
		DirAccess.make_dir_recursive_absolute(plugins_dir)
	
	for path in ResourceLoader.list_directory(plugin_dev_dir):
		if path == "_builtin/": continue
		found_plugins.append(str(plugin_dev_dir, "/", path))
	
	for plugin_path: String in found_plugins:
		_register_plugin(plugin_path)
		
	print("registered plugins: ", registered_plugins.size())
	
	for registered in registered_plugins:
		if registered.path.begins_with("res://plugins/_builtin/"): continue
		var allow_list = ConfigManager.get_value("plugins", "allow_list")
		if allow_list.has(registered):
			_load_plugin(registered.metadata.get_value("plugin_metadata", "id"))
