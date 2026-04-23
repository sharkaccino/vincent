extends TextureRect

@onready var plugin_id = get_node("../../../../../../").get_meta("id")
@onready var container = get_node("../")

func _ready() -> void:
	if plugin_id == "":
		return
	
	var plugin = PluginManager.get_plugin(plugin_id)
	if "metadata" not in plugin:
		printerr("Could not get plugin data for id: \"", plugin_id, "\"")
		return
	
	if "icon" in plugin.metadata:
		var img_path = ProjectSettings.globalize_path(plugin.metadata.icon)
		var img = Image.load_from_file(img_path)
		img.generate_mipmaps()
		texture = ImageTexture.create_from_image(img)
	else:
		container.queue_free()
