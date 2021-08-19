extends Control
signal toggle_draw_paths
signal toggle_draw_nav_polys
signal toggle_draw_spawn_radius
signal toggle_draw_attack_range
signal draw_targets

var main

func _process(_delta):
	if !visible: return
	update_buttons()


func update_buttons():
	var main = get_tree().root.get_node("Main")

	$Panel/OptionsContainer/DrawPaths.text = "Draw Paths: " + str(main.draw_paths())
	$Panel/OptionsContainer/DrawNavPolys.text = "Draw NavPolys: " + str(main.draw_nav_polys())
	$Panel/OptionsContainer/DrawAttackRange.text = "Draw Attack Ranges: " + str(main.draw_attack_ranges())
	$Panel/OptionsContainer/DrawSpawnRadius.text = "Draw Spawn Areas: " + str(main.draw_spawn_areas())
	$Panel/OptionsContainer/DrawTargets.text = "Draw Targets: " + str(main.draw_targets())

func _on_Dispatcher_toggle_debug_menu():
	visible = !visible
	update_buttons()


func _on_CloseButton_pressed():
	_on_Dispatcher_toggle_debug_menu()

func _on_DrawPaths_pressed():
	emit_signal("toggle_draw_paths")

func _on_DrawNavPolys_pressed():
	emit_signal("toggle_draw_nav_polys")

func _on_DrawSpawnRadius_pressed():
	emit_signal("toggle_draw_spawn_radius")

func _on_DrawAttackRange_pressed():
	emit_signal("toggle_draw_attack_range")

func _on_DrawTargets_pressed():
	emit_signal("draw_targets")





