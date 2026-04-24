extends VBoxContainer

@onready var save_button = %SaveButton
@onready var discard_button = %DiscardButton

func _do_save() -> void:
	ConfigManager.save_config()
	_check_button_state()

func _do_discard() -> void:
	ConfigManager.reset_volatile_config()
	_check_button_state()

func _check_button_state() -> void:
	var should_disable = ConfigManager.has_changes() == false
	save_button.disabled = should_disable
	discard_button.disabled = should_disable

func _ready() -> void:
	ConfigManager.volatile_config_updated.connect(_check_button_state)
	save_button.pressed.connect(_do_save)
	discard_button.pressed.connect(_do_discard)
