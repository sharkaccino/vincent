extends TextureButton

@onready var warning_banner = %WarningBanner
var starting_color = modulate

func _check_banner_state() -> void:
	warning_banner.visible = ConfigManager.get_volatile_value("plugins", "warning_dismissed") == false

func _pressed() -> void:
	warning_banner.visible = false
	ConfigManager.set_volatile_value("plugins", "warning_dismissed", true)

func _mouse_entered() -> void:
	modulate = Color(1,1,1)
	
func _mouse_exited() -> void:
	modulate = starting_color

func _ready() -> void:
	warning_banner.visible = ConfigManager.get_value("plugins", "warning_dismissed") == false
	
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	ConfigManager.volatile_config_updated.connect(_check_banner_state)
