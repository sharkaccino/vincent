extends CheckButton

var license_container: PanelContainer

func _pressed() -> void:
	license_container.visible = button_pressed

func _ready() -> void:
	await %ContentWrapper.ready
	license_container = %LicenseContainer
