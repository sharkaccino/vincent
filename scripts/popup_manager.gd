extends Node

func create(scene_name: String) -> Window:
	var template = get_tree().current_scene.get_node("%PopupWindowTemplate")
	var new_popup = template.duplicate()
	new_popup.set_meta("target_scene", scene_name)
	return new_popup

func dim_main_window() -> void:
	var tree = get_tree()
	var tween = tree.create_tween()
	var target = tree.current_scene
	get_viewport().gui_disable_input = true
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate", Color(0.6, 0.6, 0.6, 1), 0.5)

func undim_main_window() -> void:
	var tree = get_tree()
	var tween = tree.create_tween()
	var target = tree.current_scene
	get_viewport().gui_disable_input = false
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate", Color(1,1,1,1), 0.5)
