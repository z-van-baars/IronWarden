extends Node

# Main type stuff
signal start_multiplayer_game

signal new_action_logged
# unit production stuff
signal open_build_menu
signal unit_added
signal unit_removed
# construction stuff
signal toggle_construction_mode
signal construction_id_changed
signal new_construction
# unit stuff
signal units_selected
signal unit_update
signal unit_left_clicked
signal unit_right_clicked
signal unit_spawned
signal selection_cleared
signal reform_button_pressed
# deposit stuff
signal deposit_left_clicked
signal deposit_right_clicked
signal deposit_hovered
signal deposit_unhovered
signal deposit_exhausted
signal set_deposit_cursor
# cursor stuff
signal reset_cursor
signal set_target_location
signal open_chat_box
signal open_tech_tree
# Player signals
signal credit_resources
signal debit_resources
signal player_resources_changed
signal player_name_changed
signal remove_selected
# debug things
signal toggle_debug_menu
signal toggle_draw_paths
signal toggle_draw_nav_polys
signal toggle_draw_targets
signal toggle_draw_spawn_areas
signal toggle_draw_attack_ranges
# chat and cheats
signal all_visible
signal all_explored
# Network Stuff
onready var main = get_tree().root.get_node("Main")
onready var construction_menu = main.get_node("UILayer/ConstructionMenu")
onready var players # players[player_number] = PlayerObject
onready var units = main.get_node("GameObjects/Units")
onready var action_log = []

func new_game():
	players = main.players

func connect_signals():
	for player in players.values():
		self.connect("unit_left_clicked", player, "_on_Dispatcher_unit_left_clicked")
		self.connect("unit_right_clicked", player, "_on_Dispatcher_unit_right_clicked")
		self.connect("deposit_left_clicked", player, "_on_Dispatcher_deposit_left_clicked")
		self.connect("deposit_right_clicked", player, "_on_Dispatcher_deposit_right_clicked")

		if player.get_local():
			self.connect("player_name_changed", player, "_on_Dispatcher_name_changed")
			self.connect("reform_button_pressed", player, "_on_Dispatcher_reform_button_pressed")
			self.connect("remove_selected", player, "_on_Dispatcher_remove_selected")
			self.connect("toggle_construction_mode", player, "_on_Dispatcher_toggle_construction_mode")
			self.connect("construction_id_changed", player, "_on_Dispatcher_construction_id_changed")
		self.connect(
			"unit_added",
			main.get_node("UILayer/ResourcesWidget"),
			"_on_Dispatcher_unit_add_remove")
		self.connect(
			"unit_removed",
			main.get_node("UILayer/ResourcesWidget"),
			"_on_Dispatcher_unit_add_remove")

func log_action(action_string):
	action_log.append(action_string)
	emit_signal("new_action_logged", action_log[-1])

func _on_Units_unit_added(new_unit, player_number):
	emit_signal("unit_added")

func _on_Units_unit_removed(removed_unit, player_number):
	emit_signal("unit_removed")

	
func _on_Unit_left_clicked(unit):
	
	if unit.has_method("gather_target_set"):
		emit_signal("deposit_left_clicked", unit)
	else:
		emit_signal("unit_left_clicked", unit)

func _on_Unit_right_clicked(unit):
	if "_d_type" in unit:
		emit_signal("deposit_right_clicked", unit)
	else:
		emit_signal("unit_right_clicked", unit)

func _on_Unit_update(_unit):
	emit_signal("unit_update")

func _on_Unit_kill(unit, targeted_by):
	log_action(unit.get_display_name() + " was killed!")
	for each_unit in targeted_by:
		each_unit.clear_target_unit()
	if unit.selected:
		emit_signal("remove_selected", [unit])

func _on_Unit_credit_resources(credit_amount, player_number):
	players[player_number].credit_resources(credit_amount)

func _on_Unit_debit_resources(debit_amount, player_number):
	players[player_number].debit_resources(debit_amount)

func _on_Deposit_hovered(deposit):
	emit_signal("deposit_hovered", deposit)
	if main.local_player.gatherers_selected():
		emit_signal("set_deposit_cursor", deposit)

func _on_Deposit_unhovered():
	emit_signal("deposit_unhovered")
	emit_signal("reset_cursor")

func _on_Deposit_exhausted(deposit, gatherers):
	for gatherer in gatherers:
		gatherer._on_Target_Deposit_exhausted()
	emit_signal("deposit_exhausted", deposit)

func _on_Player_units_selected(selected_units):
	#idk what happens here if you select more than one
	# probably something bad or glitchy, please figure this out
	if selected_units[0].build_options != [] or selected_units[0].tech_options != []:
		emit_signal("open_build_menu", selected_units[0])
	emit_signal("units_selected", selected_units[0])
	emit_signal("unit_update")

func _on_Player_construction_mode_cancel(structure_type):
	if structure_type != null:
		emit_signal("construction_id_changed", null)
	else:
		emit_signal("toggle_construction_mode")

func _on_ConstructionButton_pressed():
	emit_signal("toggle_construction_mode")

func _on_ConstructionMenu_structure_button_clicked(structure_type):
	emit_signal("construction_id_changed", structure_type)

func _on_Player_new_construction(construction_id, tile_location, player_num):
	log_action("New Construction")
	emit_signal("new_construction", construction_id, tile_location, player_num)
	# emit_signal("toggle_construction_mode")

func _on_CenterWidget_reform_button_pressed():
	emit_signal("reform_button_pressed")

func _on_CenterWidget_unit_ungrouped(unit):
	emit_signal("remove_selected", [unit])

func _on_Foundation_Placed():
	emit_signal("foundation_placed")

func _on_Player_selection_cleared():
	emit_signal("selection_cleared")

func _on_Player_resources_changed(player):
	if player.get_local():
		emit_signal("player_resources_changed")

func _on_Player_set_target_location(target_location):
	emit_signal("set_target_location", target_location)

func _on_Player_toggle_debug_menu():
	emit_signal("toggle_debug_menu")

func _on_DebugMenu_toggle_draw_paths():
	log_action("Draw Paths Set to " + str(!main.draw_paths()))
	emit_signal("toggle_draw_paths")

func _on_DebugMenu_toggle_draw_nav_polys():
	log_action("Nav Polys Set to " + str(!main.draw_nav_polys()))
	emit_signal("toggle_draw_nav_polys")

func _on_DebugMenu_toggle_draw_spawn_areas():
	log_action("Draw Spawn Areas Set to " + str(!main.draw_spawn_areas()))
	emit_signal("toggle_draw_spawn_areas")

func _on_DebugMenu_toggle_draw_attack_ranges():
	log_action("Draw Attack Range Set to " + str(!main.draw_attack_range()))
	emit_signal("toggle_draw_attack_ranges")

func _on_DebugMenu_draw_targets():
	log_action("Draw Targets Set to " + str(!main.draw_targets()))
	emit_signal("toggle_draw_targets")

func _on_Build_Structure_unit_spawned(unit_type):
	log_action("New Unit Spawned - " + units.get_display_name(unit_type))
	emit_signal("unit_spawned", unit_type)

func _on_Build_Structure_set_rally_point():
	pass

func _on_Player_escape_key_pressed():
	emit_signal("player_toggle_options_menu")

func _on_Player_enter_key_pressed():
	emit_signal("open_chat_box")

func _on_OptionsMenu_open_tech_tree():
	emit_signal("open_tech_tree")

func _on_ChatBox_chat_message(msg_text):
	log_action("Player Chat: " + msg_text)



func _on_player_name_changed(new_player_name):
	emit_signal("player_name_changed", new_player_name)


func _on_Lobby_start_multiplayer_game(lobby_name, player_pool, game_settings):
	emit_signal("start_multiplayer_game", lobby_name, player_pool, game_settings)


func _on_Cheats_all_visible():
	emit_signal("all_visible")
func _on_Cheats_all_explored():
	emit_signal("all_explored")














