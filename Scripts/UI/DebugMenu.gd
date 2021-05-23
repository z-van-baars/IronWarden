extends Control
signal toggle_draw_paths
signal toggle_draw_nav_polys
signal toggle_draw_spawn_radius
signal toggle_draw_attack_range


func _process(_delta):
	if !visible: return
	update_buttons()


func update_buttons():
	var draw_paths = get_tree().root.get_node("Main").draw_paths
	var draw_nav_polys = get_tree().root.get_node("Main").draw_nav_polys
	var draw_spawn_radius = get_tree().root.get_node("Main").draw_spawn_radius
	var draw_attack_range = get_tree().root.get_node("Main").draw_attack_range

	$Panel/OptionsContainer/DrawPaths.text = "Draw Paths: " + str(draw_paths)
	$Panel/OptionsContainer/DrawNavPolys.text = "Draw NavPolys: " + str(draw_nav_polys)
	$Panel/OptionsContainer/DrawAttackRange.text = "Draw Attack Range: " + str(draw_attack_range)
	$Panel/OptionsContainer/DrawSpawnRadius.text = "Draw Spawn Radius: " + str(draw_spawn_radius)

func _on_Player_toggle_debug_menu():
	visible = !visible
	update_buttons()

func _on_CloseButton_pressed():
	_on_Player_toggle_debug_menu()

func _on_DrawPaths_pressed():
	emit_signal("toggle_draw_paths")

func _on_DrawNavPolys_pressed():
	emit_signal("toggle_draw_nav_polys")

func _on_DrawSpawnRadius_pressed():
	emit_signal("toggle_draw_spawn_radius")

func _on_DrawAttackRange_pressed():
	emit_signal("toggle_draw_attack_range")
