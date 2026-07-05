extends Node

var _fallback_lang = ProjectSettings.get_setting("internationalization/locale/fallback")
var _default_lang = TranslationServer.find_translations(_fallback_lang, true)[0]
var _translations = TranslationServer.get_translations()

var coverage = {}

func _ready() -> void:
	var defined_keys = []
	
	for key in _default_lang.get_message_list():
		var untranslated = key
		var p = key.find("\u0004")
		if p > -1:
			untranslated = key.substr(p + 1)
		defined_keys.append(untranslated)
		
	for translation in _translations:
		var found = 0.0
		
		for key in translation.get_message_list():
			var untranslated = key
			var p = key.find("\u0004")
			if p > -1:
				untranslated = key.substr(p + 1)
			
			if defined_keys.has(untranslated):
				found += 1
		
		coverage[translation.locale] = found / defined_keys.size()
