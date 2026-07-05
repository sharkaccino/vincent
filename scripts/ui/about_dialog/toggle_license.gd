extends Button

var license_container: PanelContainer

var _toggled = false

func _pressed() -> void:
	_toggled = !_toggled
	license_container.visible = _toggled
	text = "ABOUT_HIDE_LICENSE" if _toggled else "ABOUT_SHOW_LICENSE"

func _ready() -> void:
	await %ContentWrapper.ready
	license_container = %LicenseContainer
