extends OptionButton

const font_options = [
	preload("res://resources/fonts/inter/InterDisplay-Medium.ttf"),
	preload("res://resources/fonts/hyperlegible/AtkinsonHyperlegibleNext-Medium.ttf"),
	preload("res://resources/fonts/mono/SourceCodePro-Medium.ttf")
]

func _set_font(font_name: String) -> void:
	var theme_name: String = ProjectSettings.get("gui/theme/custom")
	var current_theme: Theme = load(theme_name)
	
	for i in font_options.size():
		if font_options[i].get_font_name() == font_name:
			current_theme.default_font = font_options[i]
			selected = i
			return
	
	# font not found, use default instead
	ConfigManager.set_volatile_value("interface", "font", font_options[0])

func _on_selected(index: int) -> void:
	var selected_font_name = font_options[index].get_font_name()
	ConfigManager.set_volatile_value("interface", "font", selected_font_name)

func _on_volatile_config_update() -> void:
	var selected_font_name = ConfigManager.get_volatile_value("interface", "font")
	_set_font(selected_font_name)

func _ready() -> void:
	var current_font_name = ConfigManager.get_value("interface", "font")
	_set_font(current_font_name)
	
	item_selected.connect(_on_selected)
	ConfigManager.volatile_config_updated.connect(_on_volatile_config_update)
