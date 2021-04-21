extends Node

onready var tools
onready var grid
onready var units
onready var st
onready var res


#debug junk
var draw_paths = true
var draw_nav_polys = true
var draw_spawn_radius = true
var draw_attack_range = true
var spawn_mode = false

func _ready():
	tools = $Tools
	grid = $GameMap/Grid
	st = $GameObjects/Structures
	res = $GameObjects/Resources
	units = $GameObjects/Units

	$GameMap.set_module_refs()
	res.set_module_refs()
	st.set_module_refs()
	units.set_module_refs()


	$GameMap.map_gen()
	$Nav2D.import_map_data($GameMap)



	var random_start
	# var random_start = tools.get_random_coordinates($GameMap.tiles, 1)[0]
	var all_buildable = false
	while not all_buildable:
		random_start = Vector2(
			int($GameMap.width / 2) + tools.rng.randi_range(-5, 5),
			int($GameMap.height / 2) + tools.rng.randi_range(-5, 5))
		all_buildable = true
		for each_tile in st.get_footprint_tiles(st.StructureTypes.STRUCT_COMMAND_POST, random_start):
			if not grid.get_cell(each_tile).is_buildable():
				all_buildable = false
				break
	
	st.add_structure(st.StructureTypes.STRUCT_COMMAND_POST, random_start)
	var center_point = $GameObjects/Structures/All.get_children()[0].get_center()
	# var center_point = $GameMap/TileMap.map_to_world(random_start)
	for _x in range(3):
		var random_loc = tools.circ_random(center_point, 250)
		units.add_unit(
			units.UnitTypes.UNIT_TECHPRIEST,
			center_point + random_loc + Vector2(0, -25))
	$Player/Camera2D.center_on_tile(random_start)
	$Player.set_initial_construction_options()
	$Player.set_initial_resources()
	
	
	# Menu Caching Stuff
	$UILayer/ResourcesWidget.set_module_refs()
	$UILayer/ResourcesWidget.update_labels()

	$Sounds/Stream._on_new_game()
	



