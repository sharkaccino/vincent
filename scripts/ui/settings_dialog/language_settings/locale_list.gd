extends VBoxContainer

@onready var template = $LocaleItemTemplate

func on_volatile_config_updated() -> void:
	var new_locale = ConfigManager.get_volatile_value("language", "locale")
	if new_locale == "":
		new_locale = OS.get_locale()
	
	TranslationServer.set_locale(new_locale)

func _ready() -> void:
	var translations = TranslationServer.get_translations()
	
	for translation in translations:
		var new_item: Button = template.duplicate()
		new_item.visible = true
		new_item.set_meta("Locale", translation.locale)
		
		add_child(new_item)
	
	ConfigManager.volatile_config_updated.connect(on_volatile_config_updated)
