extends Button

var license_container: PanelContainer

var _toggled = false

func _pressed() -> void:
	_toggled = !_toggled
	license_container.visible = _toggled
	text = "Hide License" if _toggled else "Show License"

func _ready() -> void:
	await %ContentWrapper.ready
	license_container = %LicenseContainer
