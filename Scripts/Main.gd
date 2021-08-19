extends Node

onready var tools
onready var grid
onready var units
onready var st
onready var res

onready var ai_player_scn = preload("res://Scenes/AIPlayer.tscn")
onready var hum_player_scn = preload("res://Scenes/HumanPlayer.tscn")
onready var local_player_scn = preload("res://Scenes/LocalPlayer.tscn")


# debug junk
enum DebugSettings {
	draw_paths,
	draw_targets,
	draw_nav_polys,
	draw_spawn_areas,
	draw_attack_ranges,
	reveal_all,
	spawn_mode}

var debug_states = {
	DebugSettings.draw_paths: true,
	DebugSettings.draw_targets: true,
	DebugSettings.draw_nav_polys: true,
	DebugSettings.draw_spawn_areas: true,
	DebugSettings.draw_attack_ranges: true,
	DebugSettings.reveal_all: false,
	DebugSettings.spawn_mode: false,}

func draw_paths():
	return debug_states[DebugSettings.draw_paths]
func draw_targets():
	return debug_states[DebugSettings.draw_targets]
func draw_nav_polys():
	return debug_states[DebugSettings.draw_nav_polys]
func draw_spawn_areas():
	return debug_states[DebugSettings.draw_spawn_areas]
func draw_attack_ranges():
	return debug_states[DebugSettings.draw_attack_ranges]
func reveal_all():
	return debug_states[DebugSettings.reveal_all]
func spawn_mode():
	return debug_states[DebugSettings.spawn_mode]

func _on_Dispatcher_toggle_draw_attack_ranges():
	debug_states[DebugSettings.draw_attack_ranges] = !draw_attack_ranges()

func _on_Dispatcher_toggle_draw_nav_polys():
	debug_states[DebugSettings.draw_nav_polys] = !draw_nav_polys()

func _on_Dispatcher_toggle_draw_paths():
	debug_states[DebugSettings.draw_attack_ranges] = !draw_attack_ranges()

func _on_Dispatcher_toggle_draw_spawn_areas():
	debug_states[DebugSettings.draw_spawn_areas] = !draw_spawn_areas()

func _on_Dispatcher_toggle_draw_targets():
	debug_states[DebugSettings.draw_targets] = !draw_targets()


var player_profiles = []
var players = {} # players[player_number] = PlayerObject
onready var active_profile = null
onready var local_player = null

func load_saved_profiles() -> PlayerProfile:
	if not tools.list_files_in_directory("res://Profiles/").empty():
		for file in tools.list_files_in_directory("res://Profiles/"):
			if file.ends_with(".tres"):
				var profile = load("res://Profiles/" + file)
				if is_valid(profile):
					player_profiles.append(load("res://Profiles/" + file))

		return player_profiles[0]
	return null

func _ready() -> void:
	tools = $Tools
	grid = $GameMap/Grid
	st = $GameObjects/Structures
	res = $GameObjects/Resources
	units = $GameObjects/Units
	#active_profile = load_saved_profiles()
	if not active_profile:
		active_profile = PlayerProfile.new()
		active_profile.set_name("default")
	$GameMap.set_module_refs()
	
	# Back-End Game Object reference setups
	res.set_module_refs()
	st.set_module_refs()
	units.set_module_refs()
	# units.build_spriteframes()
	# units.spriteframe_warmup()

	$Cursor.set_module_refs()

func is_valid(profile) -> bool:
	# Check to make sure a PlayerProfile.tres file has the right data and is
	# in the right format to be loaded in as a player
	return true

func _on_NewGame_pressed() -> void:
	start_local_game()

func _on_Dispatcher_player_name_changed(new_name) -> void:
	var profile_dir = Directory.new()
	var filename_str = "prof_" + active_profile.get_name()
	profile_dir.open("res://Profiles/")
	profile_dir.remove("res://Profiles/" + filename_str)
	active_profile.set_name(new_name)
	save_profile(active_profile)

func save_profile(profile_to_save) -> void:
	var profile_dir = Directory.new()
	profile_dir.open("res://Profiles/")
	var filename_str = "prof_" + profile_to_save.get_name() + ".tres"
	ResourceSaver.save("res://Profiles/" + filename_str, profile_to_save)


func new_ai_player(player_data):
	var new_player = ai_player_scn.instance()
	new_player.set_name(player_data.name)
	new_player.set_color(player_data.color)
	new_player.set_player_number(player_data.number)
	return new_player

func new_networked_player(player_data):
	var new_player = null
	if player_data.local:
		new_player = local_player_scn.instance()
	else:
		new_player = hum_player_scn.instance()
	if player_data.net_id:
		new_player.set_network_master(player_data.net_id)
	new_player.set_name(player_data.name)
	new_player.set_color(player_data.color)
	new_player.set_player_number(player_data.number)
	if player_data.net_id == 1:
		new_player.set_host(true)
	return new_player

func start_local_game():
	print("Mapgen Start...")
	$GameMap.map_gen()

	print("Generating Player Data...")
	var _player_1_data = {
		name = active_profile.get_name(),
		number = 0,
		color = Color.blue,
		faction = null,
		net_id = null,
		host = false,
		local = true
	}
	var _player_2_data = {
		name = "Abaddon",
		number = 1,
		color = Color.red,
		faction = "imperium",
		net_id = null,
		host = false,
		local = false
	}
	var player_pool = {
		0: _player_1_data
	}
	var ai_player_pool = {
		# 0: _player_2_data
	}
	print("Placing Initial Units...")
	for player in player_pool.values():

		var new_player = new_networked_player(player)
		if player.local:
			local_player = new_player
			new_player.set_local(true)
		players[player.number] = new_player

		$Players.add_child(new_player)
		build_player_start(new_player)
		print("Player %s complete..." % [str(new_player.get_player_number())])

	for ai_player in ai_player_pool.values():
		var new_ai_player = new_ai_player(ai_player)
		players[ai_player.number] = new_ai_player
		$Players.add_child(new_ai_player)
		build_player_start(new_ai_player)
		print("Player %s complete..." % [str(new_ai_player.get_player_number())])
	print("Generating Navigation Data...")
	$Nav2D.setup($GameMap)
	final_setup()

func _on_Dispatcher_start_multiplayer_game(lobby_name, player_pool, game_settings):
	$GameMap.map_gen()
	$Nav2D.import_map_data($GameMap)
	var ai_player_pool = {}


	for player in player_pool.values():
		var new_player = new_networked_player(player)
		if player.local:
			local_player = new_player
			new_player.set_local(true)
		players[player.number] = new_player

		$Players.add_child(new_player)
		build_player_start(new_player)

	for ai_player in ai_player_pool.values():
		var new_ai_player = new_ai_player(ai_player)
		players[ai_player.number] = new_ai_player
		$Players.add_child(new_ai_player)
		build_player_start(new_ai_player)
	
	final_setup()

func final_setup():
	print("Initializing Fog of War...")
	$GameMap/Grid.initialize_tiles()
	$GameMap/Grid.set_player_ref()
	$GameObjects/Fog.set_module_refs()
	$GameObjects/Fog.initialize_fog_tilemap()
	$GameObjects/Fog._on_FogTimer_timeout()
	print("Connecting Dispatcher...")
	$SelectionBox.connect_local_player()
	$Dispatcher.new_game()
	$Dispatcher.connect_signals()
	initialize_menus()
	print("Map Gen Complete.")

	local_player.credit_resources(
		{
		ResourceTypes.RES.BIOMASS: 10000,
		ResourceTypes.RES.ALLOY: 10000,
		ResourceTypes.RES.WARPSTONE: 10000,
		ResourceTypes.RES.ENERGY: 10000,
		ResourceTypes.RES.COMMAND: 0
	}
	)

func build_player_start(player):

	player.setup()
	player.set_initial_construction_options()
	player.set_initial_resources()
	var random_start

	var all_buildable = false
	while not all_buildable:
		random_start = Vector2(
			tools.rng.randi_range(10, $GameMap.width - 11),
			tools.rng.randi_range(10, $GameMap.height - 11))
		all_buildable = true
		for each_tile in st.get_footprint_tiles(
			StructureTypes.STRUCT.COMMAND_POST, random_start):
			if not grid.get_cell(each_tile).is_buildable():
				all_buildable = false
				break

	st.add_structure(
		StructureTypes.STRUCT.COMMAND_POST,
		random_start,
		player.get_player_number(),
		true)
	var player_structures = get_tree().get_nodes_in_group("player_" + str(player.get_player_number()) + "_structures")
	player.add_base(
		player_structures[0]
	)

	for _x in range(3):
		player.get_base().spawn_unit(UnitTypes.UTYPE.TECHPRIEST)
	for _c in range(5 * players.keys().size() + 1):
		var random_chicken_loc = Vector2(
				tools.rng.randi_range(10, $GameMap.width - 11),
				tools.rng.randi_range(10, $GameMap.height - 11))
		units.add_unit(
			UnitTypes.UTYPE.CHICKEN,
			$GameMap/TileMap.map_to_world(random_chicken_loc),
			-1)
	player.on_start($GameMap/TileMap)

func initialize_menus():
	# Menu and UI Caching and reference setup Stuff
	$UILayer/ResourcesWidget.set_module_refs()
	$UILayer/ResourcesWidget.update_labels()
	$UILayer/CenterWidget.new_game()
	$UILayer/ConstructionMenu.new_game()
	$UILayer/BuildMenu.new_game()
	$UILayer/MapWidget.set_module_refs()
	$GameObjects/BuildPreview.set_module_refs()
	$UILayer/ChatBox/Cheats.set_module_refs()

	$Sounds/Stream._on_new_game()
	$UILayer/ResourcesWidget.start_clock()


