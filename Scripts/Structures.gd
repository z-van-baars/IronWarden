extends Node2D
onready var structure_scn = preload("res://Scenes/Structure.tscn")

onready var grid
onready var nav_map
onready var structure_map
onready var res

onready var command_post_stats
onready var biomass_reactor_stats
onready var alloy_foundry_stats
onready var warpstone_refinery_stats
onready var energy_conduit_stats
onready var barracks_stats
onready var tower_stats
onready var statlines
onready var icons = {
	StructureTypes.STRUCT.COMMAND_POST: load("res://Assets/Art/Structures/imperium/command_post.png"),
	StructureTypes.STRUCT.BIOMASS_REACTOR: load("res://Assets/Art/Structures/imperium/biomass_reactor.png"),
	StructureTypes.STRUCT.ALLOY_FOUNDRY: load("res://Assets/Art/Structures/imperium/alloy_foundry.png"),
	StructureTypes.STRUCT.WARPSTONE_REFINERY: load("res://Assets/Art/Structures/imperium/warpstone_refinery.png"),
	StructureTypes.STRUCT.ENERGY_CONDUIT: load("res://Assets/Art/Structures/imperium/energy_conduit.png"),
	StructureTypes.STRUCT.BARRACKS: load("res://Assets/Art/Structures/imperium/barracks.png"),
	StructureTypes.STRUCT.TOWER: load("res://Assets/Art/Structures/imperium/tower.png")
}

onready var foundation_sprites = {
	StructureTypes.STRUCT.COMMAND_POST: load("res://Assets/Art/Structures/foundations/4x4.png"),
	StructureTypes.STRUCT.BIOMASS_REACTOR: load("res://Assets/Art/Structures/foundations/2x2.png"),
	StructureTypes.STRUCT.ALLOY_FOUNDRY: load("res://Assets/Art/Structures/foundations/2x2.png"),
	StructureTypes.STRUCT.WARPSTONE_REFINERY: load("res://Assets/Art/Structures/foundations/2x2.png"),
	StructureTypes.STRUCT.ENERGY_CONDUIT: load("res://Assets/Art/Structures/foundations/2x2.png"),
	StructureTypes.STRUCT.BARRACKS: load("res://Assets/Art/Structures/foundations/3x3.png"),
	StructureTypes.STRUCT.TOWER: load("res://Assets/Art/Structures/foundations/1x1.png")
}

onready var thumbnail = {
	StructureTypes.STRUCT.COMMAND_POST: load("res://Assets/Art/Structures/imperium/command_post.png"),
	StructureTypes.STRUCT.BIOMASS_REACTOR: load("res://Assets/Art/Structures/imperium/biomass_reactor.png"),
	StructureTypes.STRUCT.ALLOY_FOUNDRY: load("res://Assets/Art/Structures/imperium/alloy_foundry.png"),
	StructureTypes.STRUCT.WARPSTONE_REFINERY: load("res://Assets/Art/Structures/imperium/warpstone_refinery.png"),
	StructureTypes.STRUCT.ENERGY_CONDUIT: load("res://Assets/Art/Structures/imperium/energy_conduit.png"),
	StructureTypes.STRUCT.BARRACKS: load("res://Assets/Art/Structures/imperium/energy_conduit.png"),
	StructureTypes.STRUCT.TOWER: load("res://Assets/Art/Structures/imperium/energy_conduit.png")
}

onready var footprint = {
	StructureTypes.STRUCT.COMMAND_POST: Vector2(4, 4),
	StructureTypes.STRUCT.BIOMASS_REACTOR: Vector2(2, 2),
	StructureTypes.STRUCT.ALLOY_FOUNDRY: Vector2(2, 2),
	StructureTypes.STRUCT.WARPSTONE_REFINERY: Vector2(2, 2),
	StructureTypes.STRUCT.ENERGY_CONDUIT: Vector2(2, 2),
	StructureTypes.STRUCT.BARRACKS: Vector2(3, 3),
	StructureTypes.STRUCT.TOWER: Vector2(1, 1)
}

onready var build_options
onready var tech_options = {}

func set_module_refs():
	grid = get_tree().root.get_node("Main/GameMap/Grid")
	nav_map = get_tree().root.get_node("Main/Nav2D")
	structure_map = get_node("StructureMap")
	res = get_tree().root.get_node("Main/GameObjects/Resources")

	build_options = {
		StructureTypes.STRUCT.COMMAND_POST: [
			UnitTypes.UTYPE.TECHPRIEST,
			UnitTypes.UTYPE.MARINE,
			UnitTypes.UTYPE.PREDATOR,
			UnitTypes.UTYPE.LASCANNON,
			UnitTypes.UTYPE.SENTINEL,
			UnitTypes.UTYPE.CONSCRIPT],
		StructureTypes.STRUCT.BARRACKS: [
			UnitTypes.UTYPE.CONSCRIPT,
			UnitTypes.UTYPE.MARINE
		]}
	command_post_stats = {
		Stats.STAT.STRUCTURE_ID: StructureTypes.STRUCT.COMMAND_POST,
		Stats.STAT.DISPLAY_NAME: "Command Post",
		Stats.STAT.MAXHEALTH: 1000,
		Stats.STAT.MAXSHIELDS: 0,
		Stats.STAT.ARMOR: 10,
		Stats.STAT.ATTACK: 3,
		Stats.STAT.RANGE: 5,
		Stats.STAT.SIGHT: 6,
		Stats.STAT.COST: {
			ResourceTypes.RES.BIOMASS: 0,
			ResourceTypes.RES.ALLOY: 400,
			ResourceTypes.RES.WARPSTONE: 0,
			ResourceTypes.RES.ENERGY: 100,
			ResourceTypes.RES.COMMAND: 0}
	}

	biomass_reactor_stats = {
		Stats.STAT.STRUCTURE_ID: StructureTypes.STRUCT.BIOMASS_REACTOR,
		Stats.STAT.DISPLAY_NAME: "Biomass Reactor",
		Stats.STAT.MAXHEALTH: 200,
		Stats.STAT.MAXSHIELDS: 0,
		Stats.STAT.ARMOR: 10,
		Stats.STAT.ATTACK: 3,
		Stats.STAT.RANGE: 5,
		Stats.STAT.SIGHT: 6,
		Stats.STAT.COST: {
			ResourceTypes.RES.BIOMASS: 0,
			ResourceTypes.RES.ALLOY: 100,
			ResourceTypes.RES.WARPSTONE: 0,
			ResourceTypes.RES.ENERGY: 0,
			ResourceTypes.RES.COMMAND: 0}
	}

	alloy_foundry_stats = {
		Stats.STAT.STRUCTURE_ID: StructureTypes.STRUCT.ALLOY_FOUNDRY,
		Stats.STAT.DISPLAY_NAME: "Alloy Foundry",
		Stats.STAT.MAXHEALTH: 200,
		Stats.STAT.MAXSHIELDS: 0,
		Stats.STAT.ARMOR: 10,
		Stats.STAT.ATTACK: 0,
		Stats.STAT.RANGE: 0,
		Stats.STAT.SIGHT: 6,
		Stats.STAT.COST: {
			ResourceTypes.RES.BIOMASS: 0,
			ResourceTypes.RES.ALLOY: 100,
			ResourceTypes.RES.WARPSTONE: 0,
			ResourceTypes.RES.ENERGY: 0,
			ResourceTypes.RES.COMMAND: 0}
	}

	warpstone_refinery_stats = {
		Stats.STAT.STRUCTURE_ID: StructureTypes.STRUCT.WARPSTONE_REFINERY,
		Stats.STAT.DISPLAY_NAME: "Warpstone Refinery",
		Stats.STAT.MAXHEALTH: 500,
		Stats.STAT.MAXSHIELDS: 0,
		Stats.STAT.ARMOR: 10,
		Stats.STAT.ATTACK: 0,
		Stats.STAT.RANGE: 0,
		Stats.STAT.SIGHT: 6,
		Stats.STAT.COST: {
			ResourceTypes.RES.BIOMASS: 0,
			ResourceTypes.RES.ALLOY: 100,
			ResourceTypes.RES.WARPSTONE: 0,
			ResourceTypes.RES.ENERGY: 0,
			ResourceTypes.RES.COMMAND: 0}
	}

	energy_conduit_stats = {
		Stats.STAT.STRUCTURE_ID: StructureTypes.STRUCT.ENERGY_CONDUIT,
		Stats.STAT.DISPLAY_NAME: "Energy Conduit",
		Stats.STAT.MAXHEALTH: 200,
		Stats.STAT.MAXSHIELDS: 0,
		Stats.STAT.ARMOR: 10,
		Stats.STAT.ATTACK: 0,
		Stats.STAT.RANGE: 0,
		Stats.STAT.SIGHT: 6,
		Stats.STAT.COST: {
			ResourceTypes.RES.BIOMASS: 0,
			ResourceTypes.RES.ALLOY: 200,
			ResourceTypes.RES.WARPSTONE: 0,
			ResourceTypes.RES.ENERGY: 0,
			ResourceTypes.RES.COMMAND: 0}
	}
	

	barracks_stats = {
		Stats.STAT.STRUCTURE_ID: StructureTypes.STRUCT.BARRACKS,
		Stats.STAT.DISPLAY_NAME: "Barracks",
		Stats.STAT.MAXHEALTH: 300,
		Stats.STAT.MAXSHIELDS: 0,
		Stats.STAT.ARMOR: 10,
		Stats.STAT.ATTACK: 0,
		Stats.STAT.RANGE: 0,
		Stats.STAT.SIGHT: 6,
		Stats.STAT.COST: {
			ResourceTypes.RES.BIOMASS: 0,
			ResourceTypes.RES.ALLOY: 400,
			ResourceTypes.RES.WARPSTONE: 0,
			ResourceTypes.RES.ENERGY: 20,
			ResourceTypes.RES.COMMAND: 0}
	}

	tower_stats = {
		Stats.STAT.STRUCTURE_ID: StructureTypes.STRUCT.TOWER,
		Stats.STAT.DISPLAY_NAME: "Tower",
		Stats.STAT.MAXHEALTH: 300,
		Stats.STAT.MAXSHIELDS: 0,
		Stats.STAT.ARMOR: 10,
		Stats.STAT.ATTACK: 5,
		Stats.STAT.RANGE: 5,
		Stats.STAT.SIGHT: 6,
		Stats.STAT.COST: {
			ResourceTypes.RES.BIOMASS: 0,
			ResourceTypes.RES.ALLOY: 200,
			ResourceTypes.RES.WARPSTONE: 0,
			ResourceTypes.RES.ENERGY: 50,
			ResourceTypes.RES.COMMAND: 0}
	}

	statlines = {
		StructureTypes.STRUCT.COMMAND_POST: command_post_stats,
		StructureTypes.STRUCT.BIOMASS_REACTOR: biomass_reactor_stats,
		StructureTypes.STRUCT.ALLOY_FOUNDRY: alloy_foundry_stats,
		StructureTypes.STRUCT.WARPSTONE_REFINERY: warpstone_refinery_stats,
		StructureTypes.STRUCT.ENERGY_CONDUIT: energy_conduit_stats,
		StructureTypes.STRUCT.BARRACKS: barracks_stats,
		StructureTypes.STRUCT.TOWER: tower_stats
	}

func add_structure(player_own : int, structure_type : int, coordinates: Vector2, constructed=false) -> Object:
	var new_structure = structure_scn.instance()
	$All.add_child(new_structure)
	new_structure.setup(
		player_own,
		structure_type,
		coordinates,
		$StructureMap.map_to_world(coordinates),
		constructed)
	# nav_map.update_nav_tile(coordinates, -1)
	# print(new_structure.get_footprint())
	# for each_tile in new_structure.get_footprint():
		# nav_map.add_tile_outline(each_tile)
	# var tile_coord = Vector2(new_structure.get_footprint()[0])
	grid.set_tiles_to_dirt(new_structure.get_footprint())
	grid.set_structure(new_structure.get_footprint(), new_structure)
	return new_structure

func get_structures():
	return $All.get_children()

func get_width(structure_type):
	return footprint[structure_type].x

func get_height(structure_type):
	return footprint[structure_type].y

func get_cost(structure_type):
	return statlines[structure_type][Stats.STAT.COST]

func get_display_name(structure_type):
	return statlines[structure_type][Stats.STAT.DISPLAY_NAME]


func get_footprint_tiles(structure_type, coordinates):
	var footprint_tiles = []
	var start = Vector2(coordinates)
	for y in range(footprint[structure_type].y):
		for x in range(footprint[structure_type].x):
			footprint_tiles.append(Vector2(start.x + x, start.y + y))

	return footprint_tiles

func get_footprint_offset(structure_type):
	return Vector2(0, -26 * sqrt(
		get_width(structure_type) * get_height(structure_type)))


func _on_Dispatcher_new_construction(player_own, structure_type, coordinates):
	add_structure(player_own, structure_type, coordinates)
