extends Control
onready var main = get_tree().root.get_node("Main")

func _ready():
	pass # Replace with function body.

func toggle_debug_menu():
	print(visible)
	visible = not visible
	print(visible)
	get_tree().paused = not get_tree().paused

func _on_DebugMenuButton_pressed():
	toggle_debug_menu()

func redraw():
	for each in $Panel/OptionsContainer.get_children():
		pass
	$Panel/OptionsContainer/DrawPaths.text = "Draw Paths : " + str(main.draw_paths).capitalize()
	$Panel/OptionsContainer/DrawNavPolys.text = "Draw Nav Polys : " + str(main.draw_nav_polys).capitalize()

func _on_CloseButton_pressed():
	toggle_debug_menu()

func _on_DrawPaths_pressed():
	main.draw_paths = not main.draw_paths
	redraw()

func _on_DrawNavPolys_pressed():
	main.draw_nav_polys = not main.draw_nav_polys
	redraw()

func _on_Player_toggle_debug_menu():
	toggle_debug_menu()
