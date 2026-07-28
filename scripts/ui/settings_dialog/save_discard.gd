extends VBoxContainer

@onready var save_button = %SaveButton
@onready var discard_button = %DiscardButton

func do_save() -> void:
	ConfigManager.save_config()
	check_button_state()

func do_discard() -> void:
	ConfigManager.reset_volatile_config()
	check_button_state()

func check_button_state() -> void:
	var should_disable = ConfigManager.has_changes() == false
	save_button.disabled = should_disable
	discard_button.disabled = should_disable

func on_window_close() -> void:
	if ConfigManager.has_changes():
		ConfigManager.reset_volatile_config()

func _ready() -> void:
	ConfigManager.volatile_config_updated.connect(check_button_state)
	save_button.pressed.connect(do_save)
	discard_button.pressed.connect(do_discard)
	get_window().close_requested.connect(on_window_close)

func _exit_tree() -> void:
	on_window_close()
