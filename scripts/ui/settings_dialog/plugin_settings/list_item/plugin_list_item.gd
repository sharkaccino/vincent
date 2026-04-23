extends PanelContainer

#@onready var toggle_button = %PluginEnable
#@onready var icon_container = %PluginIconContainer
#@onready var icon_panel = %PluginIcon
#@onready var name_label = %PluginName
#@onready var description_label = %PluginDescription
#@onready var version_label = %PluginVersion
#@onready var id_label = %PluginID
#@onready var url_button = %PluginURL
#@onready var settings_container = %PluginSettingsContainer

func _ready() -> void:
	var plugin_id = get_meta("id")
	if plugin_id == "":
		visible = false
		return
	
	var plugin = PluginManager.get_plugin(plugin_id)
	if "metadata" not in plugin:
		printerr("Could not get plugin data for id: \"", plugin_id, "\"")
		return
	
	#id_label.text = plugin_id
	#
	#
	
