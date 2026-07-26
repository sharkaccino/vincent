extends VBoxContainer

@onready var mode_rgb := %RGBMode
@onready var mode_hsv := %HSVMode
@onready var mode_hsl := %HSLMode

@onready var ch1_label := %CH1Label
@onready var ch2_label := %CH2Label
@onready var ch3_label := %CH3Label
@onready var ch4_label := %CH4Label

@onready var ch1_slider := %CH1Slider
@onready var ch2_slider := %CH2Slider
@onready var ch3_slider := %CH3Slider
@onready var ch4_slider := %CH4Slider

@onready var ch1_spinbox := %CH1Value
@onready var ch2_spinbox := %CH2Value
@onready var ch3_spinbox := %CH3Value
@onready var ch4_spinbox := %CH4Value

enum SliderMode {
	RGB,
	HSV,
	HSL
}

var debounce_sliders := false
var debounce_spinboxes := false
var mode := SliderMode.RGB

# TODO: add config option to allow decimal values

func update_gradients() -> void:
	if (mode == SliderMode.RGB):
		ch1_slider.material.set_shader_parameter("mode", 0)
		ch2_slider.material.set_shader_parameter("mode", 0)
		ch3_slider.material.set_shader_parameter("mode", 0)
		
		var r1 = Color(StateManager.primary_color)
		var r2 = Color(StateManager.primary_color)
		r1.r = 0.0
		r2.r = 1.0
		ch1_slider.material.set_shader_parameter("color1", r1)
		ch1_slider.material.set_shader_parameter("color2", r2)
		
		var g1 = Color(StateManager.primary_color)
		var g2 = Color(StateManager.primary_color)
		g1.g = 0.0
		g2.g = 1.0
		ch2_slider.material.set_shader_parameter("color1", g1)
		ch2_slider.material.set_shader_parameter("color2", g2)
		
		var b1 = Color(StateManager.primary_color)
		var b2 = Color(StateManager.primary_color)
		b1.b = 0.0
		b2.b = 1.0
		ch3_slider.material.set_shader_parameter("color1", b1)
		ch3_slider.material.set_shader_parameter("color2", b2)
	elif (mode == SliderMode.HSV):
		ch1_slider.material.set_shader_parameter("mode", 1)
		ch2_slider.material.set_shader_parameter("mode", 0)
		ch3_slider.material.set_shader_parameter("mode", 0)
		
		var hsv = Vector4(
			StateManager.primary_color.h,
			StateManager.primary_color.s,
			StateManager.primary_color.v,
			StateManager.primary_color.a
		)
		ch1_slider.material.set_shader_parameter("color1", hsv)
		
		var s1 = Color(StateManager.primary_color)
		var s2 = Color(StateManager.primary_color)
		s1.s = 0.0
		s2.s = 1.0
		s2.h = ch1_slider.value
		ch2_slider.material.set_shader_parameter("color1", s1)
		ch2_slider.material.set_shader_parameter("color2", s2)
		
		var v1 = Color(StateManager.primary_color)
		var v2 = Color(StateManager.primary_color)
		v1.v = 0.0
		v2.v = 1.0
		v2.s = ch2_slider.value
		v2.h = ch1_slider.value
		ch3_slider.material.set_shader_parameter("color1", v1)
		ch3_slider.material.set_shader_parameter("color2", v2)
	elif (mode == SliderMode.HSL):
		ch1_slider.material.set_shader_parameter("mode", 1)
		ch2_slider.material.set_shader_parameter("mode", 0)
		ch3_slider.material.set_shader_parameter("mode", 2)
		
		var hsv = Vector4(
			StateManager.primary_color.h,
			StateManager.primary_color.s,
			StateManager.primary_color.v,
			StateManager.primary_color.a
		)
		ch1_slider.material.set_shader_parameter("color1", hsv)
		
		var s1 = Utils.hsl_to_color(Vector4(
			ch1_slider.value,
			0.0,
			ch3_slider.value,
			ch4_slider.value,
		))
		var s2 = Utils.hsl_to_color(Vector4(
			ch1_slider.value,
			1.0,
			ch3_slider.value,
			ch4_slider.value,
		))
		ch2_slider.material.set_shader_parameter("color1", s1)
		ch2_slider.material.set_shader_parameter("color2", s2)
		
		var lgrad = Vector4(
			ch1_slider.value,
			ch2_slider.value,
			ch3_slider.value,
			ch4_slider.value
		)
		ch3_slider.material.set_shader_parameter("color1", lgrad)
	
	var a1 = Color(StateManager.primary_color)
	var a2 = Color(StateManager.primary_color)
	a1.a = 0.0
	a2.a = 1.0
	ch4_slider.material.set_shader_parameter("color1", a1)
	ch4_slider.material.set_shader_parameter("color2", a2)

func reset_all_sliders() -> void:
	if (debounce_sliders):
		update_gradients()
		debounce_sliders = false
		return
	
	var current_color = StateManager.primary_color
	
	if (mode == SliderMode.RGB):
		ch1_slider.set_value(current_color.r)
		ch2_slider.set_value(current_color.g)
		ch3_slider.set_value(current_color.b)
		ch4_slider.set_value(current_color.a)
	elif (mode == SliderMode.HSV):
		ch1_slider.set_value(current_color.h)
		ch2_slider.set_value(current_color.s)
		ch3_slider.set_value(current_color.v)
		ch4_slider.set_value(current_color.a)
	elif (mode == SliderMode.HSL):
		var hsl = Utils.color_to_hsl(current_color)
		
		ch1_slider.set_value(hsl.x)
		ch2_slider.set_value(hsl.y)
		ch3_slider.set_value(hsl.z)
		ch4_slider.set_value(hsl.w)
	
	update_gradients()

func reset_all_spinboxes() -> void:
	if (debounce_spinboxes):
		debounce_spinboxes = false
		return
		
	var current_color = StateManager.primary_color
	
	ch1_spinbox.max_value = 1000.0
	ch2_spinbox.max_value = 1000.0
	ch3_spinbox.max_value = 1000.0
	ch4_spinbox.max_value = 1000.0
	
	if (mode == SliderMode.RGB):
		ch1_label.text = "R"
		ch2_label.text = "G"
		ch3_label.text = "B"
	
		ch1_spinbox.set_value_no_signal(current_color.r * 255)
		ch2_spinbox.set_value_no_signal(current_color.g * 255)
		ch3_spinbox.set_value_no_signal(current_color.b * 255)
		ch4_spinbox.set_value_no_signal(current_color.a * 255)
		
		ch1_spinbox.max_value = 255.0
		ch2_spinbox.max_value = 255.0
		ch3_spinbox.max_value = 255.0
	elif (mode == SliderMode.HSV):
		ch1_label.text = "H"
		ch2_label.text = "S"
		ch3_label.text = "V"
	
		ch1_spinbox.set_value_no_signal(current_color.h * 360)
		ch2_spinbox.set_value_no_signal(current_color.s * 100)
		ch3_spinbox.set_value_no_signal(current_color.v * 100)
		ch4_spinbox.set_value_no_signal(current_color.a * 255)
		
		ch1_spinbox.max_value = 360.0
		ch2_spinbox.max_value = 100.0
		ch3_spinbox.max_value = 100.0
	elif (mode == SliderMode.HSL):
		ch1_label.text = "H"
		ch2_label.text = "S"
		ch3_label.text = "L"
	
		var hsl = Utils.color_to_hsl(current_color)
		ch1_spinbox.set_value_no_signal(hsl.x * 360)
		ch2_spinbox.set_value_no_signal(hsl.y * 100)
		ch3_spinbox.set_value_no_signal(hsl.z * 100)
		ch4_spinbox.set_value_no_signal(hsl.w * 255)
		
		ch1_spinbox.max_value = 360.0
		ch2_spinbox.max_value = 100.0
		ch3_spinbox.max_value = 100.0

func on_color_changed() -> void:
	reset_all_sliders()
	reset_all_spinboxes()

func set_mode_rgb() -> void:
	mode = SliderMode.RGB
	
	reset_all_sliders()
	reset_all_spinboxes()

func set_mode_hsv() -> void:
	mode = SliderMode.HSV
	
	reset_all_sliders()
	reset_all_spinboxes()

func set_mode_hsl() -> void:
	mode = SliderMode.HSL
	
	reset_all_sliders()
	reset_all_spinboxes()

func on_slider1_changed() -> void:
	var new_color = Color(StateManager.primary_color)
	var new_value: float = ch1_slider.value
	var spinbox: SpinBox = ch1_spinbox
	
	if (mode == SliderMode.RGB):
		new_color.r = new_value
		spinbox.set_value_no_signal(new_value * 255)
	elif (mode == SliderMode.HSV || mode == SliderMode.HSL):
		new_color.h = new_value
		spinbox.set_value_no_signal(new_value * 360)
	
	debounce_sliders = true
	debounce_spinboxes = true
	StateManager.set_primary_color(new_color)

func on_slider2_changed() -> void:
	var new_color = Color(StateManager.primary_color)
	var new_value: float = ch2_slider.value
	var spinbox: SpinBox = ch2_spinbox
	
	if (mode == SliderMode.RGB):
		new_color.g = new_value
		spinbox.set_value_no_signal(new_value * 255)
	elif (mode == SliderMode.HSV):
		new_color.s = new_value
		new_color.v = ch3_slider.value
		new_color.h = ch1_slider.value
		
		spinbox.set_value_no_signal(new_value * 100)
	elif (mode == SliderMode.HSL):
		new_color = Utils.hsl_to_color(Vector4(
			ch1_slider.value,
			new_value,
			ch3_slider.value,
			ch4_slider.value,
		))
		spinbox.set_value_no_signal(new_value * 100)
	
	debounce_sliders = true
	debounce_spinboxes = true
	StateManager.set_primary_color(new_color)

func on_slider3_changed() -> void:
	var new_color = Color(StateManager.primary_color)
	var new_value: float = ch3_slider.value
	var spinbox: SpinBox = ch3_spinbox
	
	if (mode == SliderMode.RGB):
		new_color.b = new_value
		spinbox.set_value_no_signal(new_value * 255)
	elif (mode == SliderMode.HSV):
		new_color.h = ch1_slider.value
		new_color.s = ch2_slider.value
		new_color.v = new_value
		spinbox.set_value_no_signal(new_value * 100)
	elif (mode == SliderMode.HSL):
		new_color = Utils.hsl_to_color(Vector4(
			ch1_slider.value,
			ch2_slider.value,
			new_value,
			ch4_slider.value,
		))
		
		spinbox.set_value_no_signal(new_value * 100)
	
	debounce_sliders = true
	debounce_spinboxes = true
	StateManager.set_primary_color(new_color)

func on_slider4_changed() -> void:
	var new_color = Color(StateManager.primary_color)
	var new_value: float = ch4_slider.value
	var spinbox: SpinBox = ch4_spinbox
	
	new_color.a = new_value
	spinbox.set_value_no_signal(new_value * 255)
	
	debounce_sliders = true
	debounce_spinboxes = true
	StateManager.set_primary_color(new_color)

func on_spinbox1_changed(new_value: float) -> void:
	var new_color = Color(StateManager.primary_color)
	
	if (mode == SliderMode.RGB):
		var normalized = new_value / 255.0
		new_color.r = normalized
		ch1_slider.set_value(normalized)
	elif (mode == SliderMode.HSV || mode == SliderMode.HSL):
		var normalized = new_value / 360.0
		new_color.h = normalized
		ch1_slider.set_value(normalized)
		
	debounce_sliders = true
	debounce_spinboxes = true
	StateManager.set_primary_color(new_color)

func on_spinbox2_changed(new_value: float) -> void:
	var new_color = Color(StateManager.primary_color)
	
	if (mode == SliderMode.RGB):
		var normalized = new_value / 255.0
		new_color.g = normalized
		ch2_slider.set_value(normalized)
	elif (mode == SliderMode.HSV):
		var normalized = new_value / 100.0
		
		new_color.v = ch3_slider.value
		new_color.s = normalized
		new_color.h = ch1_slider.value
		
		ch2_slider.set_value(normalized)
	elif (mode == SliderMode.HSL):
		var normalized = new_value / 100.0
		
		new_color = Utils.hsl_to_color(Vector4(
			ch1_slider.value,
			normalized,
			ch3_slider.value,
			ch4_slider.value,
		))
		
		ch2_slider.set_value(normalized)
	
	debounce_sliders = true
	debounce_spinboxes = true
	StateManager.set_primary_color(new_color)

func on_spinbox3_changed(new_value: float) -> void:
	var new_color = Color(StateManager.primary_color)
	
	if (mode == SliderMode.RGB):
		var normalized = new_value / 255.0
		new_color.b = normalized
		ch3_slider.set_value(normalized)
	elif (mode == SliderMode.HSV):
		var normalized = new_value / 100.0
		new_color.v = normalized
		new_color.s = ch2_slider.value
		new_color.h = ch1_slider.value
		
		ch3_slider.set_value(normalized)
	elif (mode == SliderMode.HSL):
		var normalized = new_value / 100.0
		new_color = Utils.hsl_to_color(Vector4(
			ch1_slider.value,
			ch2_slider.value,
			normalized,
			ch4_slider.value,
		))
		
		ch3_slider.set_value(normalized)
	
	debounce_sliders = true
	debounce_spinboxes = true
	StateManager.set_primary_color(new_color)

func on_spinbox4_changed(new_value: float) -> void:
	var new_color = Color(StateManager.primary_color)
	
	var normalized = new_value / 255.0
	new_color.a = normalized
	ch4_slider.set_value(normalized)
	
	debounce_sliders = true
	debounce_spinboxes = true
	StateManager.set_primary_color(new_color)

func _ready() -> void:
	var spinboxes: Array[SpinBox] = [
		ch1_spinbox,
		ch2_spinbox,
		ch3_spinbox,
		ch4_spinbox
	]
	
	for spinbox in spinboxes:
		var line_edit = spinbox.get_line_edit()
		line_edit.custom_maximum_size.x = 32.0
		spinbox.queue_redraw()
	
	mode_rgb.pressed.connect(set_mode_rgb)
	mode_hsv.pressed.connect(set_mode_hsv)
	mode_hsl.pressed.connect(set_mode_hsl)
	
	ch1_slider.value_changed.connect(on_slider1_changed)
	ch2_slider.value_changed.connect(on_slider2_changed)
	ch3_slider.value_changed.connect(on_slider3_changed)
	ch4_slider.value_changed.connect(on_slider4_changed)
	
	ch1_spinbox.value_changed.connect(on_spinbox1_changed)
	ch2_spinbox.value_changed.connect(on_spinbox2_changed)
	ch3_spinbox.value_changed.connect(on_spinbox3_changed)
	ch4_spinbox.value_changed.connect(on_spinbox4_changed)
	
	StateManager.primary_color_changed.connect(on_color_changed)
	
	update_gradients()
	reset_all_sliders()
	reset_all_spinboxes()
