extends Node

signal new_action_logged
signal open_build_menu
signal builder_unit_selected
signal unit_selected
signal unit_update
signal unit_left_clicked
signal unit_spawned
signal unit_confirm
signal selection_cleared
signal resource_left_clicked
signal resource_right_clicked
signal resource_hovered
signal resource_unhovered
signal resource_selected
signal set_resource_cursor
signal reset_cursor
signal set_rally_point
signal set_target_location

onready var player = get_tree().root.get_node("Main/Player")
onready var units = get_tree().root.get_node("Main/GameObjects/Units")

onready var action_log = []

func log_action(action_string):
	action_log.append(action_string)
	emit_signal("new_action_logged", action_log[-1])


func _on_Unit_left_clicked(unit):
	emit_signal("unit_left_clicked", unit)

func _on_Unit_confirm(unit):
	log_action("Unit confirmed")
	emit_signal("unit_confirm", unit)

func _on_Unit_update(unit):
	emit_signal("unit_update")


func _on_Player_unit_selected(unit):
	#idk what happens here if you select more than one
	# probably something bad or glitchy, please figure this out
	if unit.build_options != [] or unit.tech_options != []:
		emit_signal("open_build_menu", unit)
	emit_signal("unit_selected", unit)
	if "utype" in unit and unit.utype == units.UnitTypes.UNIT_ENGINEER:
		# right now we're jamming the unit selected into a new list so that we 
		# don't have to re-write the code in the construction menu, but at some
		# point we'll have to make it so this signal just takes a list as input
		emit_signal("builder_unit_selected", [unit])

func _on_Player_resource_selected(resource):
	emit_signal("resource_selected", resource)

func _on_Player_selection_cleared():
	emit_signal("selection_cleared")

func _on_Player_unit_move_to(target_location):
	emit_signal("set_target_location", target_location)


func _on_Resource_left_clicked(resource):
	emit_signal("resource_left_clicked", resource)

func _on_Resource_right_clicked(resource):
	emit_signal("resource_right_clicked", resource)

func _on_Resource_hovered(resource):
	emit_signal("resource_hovered", resource)
	if player.gatherers_selected():
		emit_signal("set_resource_cursor", resource)

func _on_Resource_unhovered():
	emit_signal("resource_unhovered")
	emit_signal("reset_cursor")


func _on_DebugMenu_toggle_draw_paths():
	log_action("Draw Paths Set to " + str(!get_tree().root.get_node("Main").draw_paths))
	get_tree().root.get_node("Main").draw_paths = !get_tree().root.get_node("Main").draw_paths

func _on_DebugMenu_toggle_draw_nav_polys():
	log_action("Nav Polys Set to " + str(!get_tree().root.get_node("Main").draw_nav_polys))
	get_tree().root.get_node("Main").draw_nav_polys = !get_tree().root.get_node("Main").draw_nav_polys

func _on_DebugMenu_toggle_draw_spawn_radius():
	log_action("Draw Spawn Radius Set to " + str(!get_tree().root.get_node("Main").draw_spawn_radius))
	get_tree().root.get_node("Main").draw_spawn_radius = !get_tree().root.get_node("Main").draw_spawn_radius

func _on_DebugMenu_toggle_draw_attack_range():
	log_action("Draw Attack Range Set to " + str(!get_tree().root.get_node("Main").draw_attack_range))
	get_tree().root.get_node("Main").draw_attack_range = !get_tree().root.get_node("Main").draw_attack_range

func _on_Build_Structure_unit_spawned(unit_type):
	log_action("New Unit Spawned")
	emit_signal("unit_spawned", unit_type)

func _on_Build_Structure_set_rally_point():
	log_action("Rally Point Set")
	emit_signal("set_rally_point")
