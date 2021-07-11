extends Node

# Main type stuff
signal start_multiplayer_game

signal new_action_logged
# unit production stuff
signal open_build_menu
# construction stuff
signal open_construction_menu
signal construction_mode_entered
signal construction_mode_exited
signal new_construction
# unit stuff
signal unit_selected
signal unit_update
signal unit_left_clicked
signal unit_right_clicked
signal unit_spawned
signal selection_cleared
# deposit stuff
signal deposit_left_clicked
signal deposit_right_clicked
signal deposit_hovered
signal deposit_unhovered
signal set_deposit_cursor
# cursor stuff
signal reset_cursor
signal set_target_location
signal open_chat_box
signal open_tech_tree
# Player signals
signal credit_resources
signal debit_resources
signal player_name_changed
# Network Stuff
onready var main = get_tree().root.get_node("Main")
onready var construction_menu = main.get_node("UILayer/ConstructionMenu")
onready var players
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
		self.connect("construction_mode_entered", player, "_on_Dispatcher_construction_mode_entered")
		self.connect("construction_mode_exited", player, "_on_Dispatcher_construction_mode_exited")
		if player.get_local():
			self.connect("player_name_changed", player, "_on_Dispatcher_name_changed")

func log_action(action_string):
	action_log.append(action_string)
	emit_signal("new_action_logged", action_log[-1])

func _on_Unit_left_clicked(unit):
	
	if unit.has_method("gather_target_set"):
		emit_signal("deposit_left_clicked", unit)
	else:
		emit_signal("unit_left_clicked", unit)

func _on_Unit_right_clicked(unit):
	if unit.has_method("gather_target_set"):
		emit_signal("deposit_right_clicked", unit)
	else:
		emit_signal("unit_right_clicked", unit)

func _on_Unit_update(_unit):
	emit_signal("unit_update")

func _on_Unit_kill(unit, targeted_by):
	log_action(unit.get_display_name() + " was killed!")
	main.local_player.clear_selected()
	for each_unit in targeted_by:
		each_unit.clear_target_unit()
	if unit.selected:
		emit_signal("selection_cleared")

func _on_Deposit_hovered(deposit):
	emit_signal("deposit_hovered", deposit)
	if main.local_player.gatherers_selected():
		emit_signal("set_deposit_cursor", deposit)

func _on_Deposit_unhovered():
	emit_signal("deposit_unhovered")
	emit_signal("reset_cursor")

func _on_Player_unit_selected(unit):
	#idk what happens here if you select more than one
	# probably something bad or glitchy, please figure this out
	if unit.build_options != [] or unit.tech_options != []:
		emit_signal("open_build_menu", unit)
	emit_signal("unit_selected", unit)

func _on_ConstructionButton_pressed():
	emit_signal("open_construction_menu")

func _on_ConstructionMenu_structure_button_clicked(structure_type):
	emit_signal("construction_mode_entered", structure_type)

func _on_Foundation_Placed():
	emit_signal("foundation_placed")

func _on_Player_selection_cleared():
	emit_signal("selection_cleared")

func _on_Player_unit_move_to(target_location):
	emit_signal("set_target_location", target_location)

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
	log_action("New Unit Spawned - " + units.get_display_name(unit_type))
	emit_signal("unit_spawned", unit_type)

func _on_Player_escape_key_pressed():
	emit_signal("player_toggle_options_menu")

func _on_Player_enter_key_pressed():
	emit_signal("open_chat_box")

func _on_OptionsMenu_open_tech_tree():
	emit_signal("open_tech_tree")

func _on_ChatBox_chat_message(msg_text):
	log_action("Player Chat: " + msg_text)

func _on_Player_construction_mode_right_clicked():
	emit_signal("construction_mode_exited")

func _on_Player_new_construction(player_num, construction_id, tile_location):
	log_action("New Construction")
	emit_signal("new_construction", player_num, construction_id, tile_location)
	emit_signal("construction_mode_exited")

func _on_player_name_changed(new_player_name):
	emit_signal("player_name_changed", new_player_name)


func _on_Lobby_start_multiplayer_game(lobby_name, player_pool, game_settings):
	emit_signal("start_multiplayer_game", lobby_name, player_pool, game_settings)
