extends Button

@onready var checkbox = $MarginContainer/HBoxContainer/CheckBox
@onready var locale_name_label = $MarginContainer/HBoxContainer/LocaleNameLabel
@onready var coverage_label = $MarginContainer/HBoxContainer/CoverageLabel
@onready var coverage_bar = $MarginContainer/HBoxContainer/CoverageBar

@onready var locale = get_meta("Locale")

const native_names = preload("res://resources/native_locale_names.json").data

var default_lang = ProjectSettings.get_setting("internationalization/locale/fallback")

func is_selected() -> bool:
	var new_locale = ConfigManager.get_volatile_value("language", "locale")
	if new_locale == "":
		new_locale = OS.get_locale()
		
	return new_locale == locale

func update_coverage_string() -> void:
	if !is_inside_tree(): return
	await get_tree().process_frame
	var coverage: float = LocaleCoverageTester.coverage[locale]
	coverage_label.text = tr("SETTINGS_LANGUAGE_COVERAGE").format({
		percentage = snappedf(coverage * 100, 0.1)
	})

func on_volatile_config_updated() -> void:
	update_coverage_string()
	if is_selected(): 
		checkbox.button_pressed = true

func on_visibility_changed() -> void:
	# make sure currently selected locale is visible
	# when opening the language settings page
	if is_visible_in_tree() and is_selected():
		await get_tree().process_frame
		var scroller: ScrollContainer = get_node("../../../")
		scroller.ensure_control_visible(self)

func _pressed() -> void:
	if checkbox.button_pressed: return
	checkbox.button_pressed = true
	ConfigManager.set_volatile_value("language", "locale", locale)

func _ready() -> void:
	if locale == "":
		visible = false
		return
	
	var current_lang = ConfigManager.get_value("language", "locale")
	if current_lang == "":
		current_lang = OS.get_locale()
	
	if locale == current_lang:
		checkbox.button_pressed = true
		TranslationServer.set_locale(current_lang)
	
	# if all else fails just show the locale code
	locale_name_label.text = locale
	
	for locale_group in native_names:
		if locale_group[0] == locale:
			locale_name_label.text = locale_group[1]
			break
	
	var coverage: float = LocaleCoverageTester.coverage[locale]
	
	update_coverage_string()
	
	# change bar color depending on coverage percentage
	# green (120deg) = best coverage
	# red (0deg) = worst coverage
	coverage_bar.value = coverage * 100
	coverage_bar.modulate = Color.from_hsv(lerpf(0, 120.0 / 360.0, coverage), 0.66, 1)
	
	ConfigManager.volatile_config_updated.connect(on_volatile_config_updated)
	visibility_changed.connect(on_visibility_changed)
