extends Node2D
onready var structure_scn = preload("res://Scenes/Structure.tscn")

onready var grid
onready var nav_map
onready var structure_map
onready var units
onready var res

enum StructureTypes {
	STRUCT_COMMAND_POST,
	STRUCT_BIOMASS_REACTOR,
	STRUCT_ALLOY_FOUNDRY,
	STRUCT_WARPSTONE_REFINERY,
	STRUCT_ENERGY_CONDUIT
}

enum ResourceTypes {
	BIOMASS,
	ALLOY,
	WARPSTONE,
	ENERGY,
	COMMAND
}

enum Stats {
	STRUCTURE_ID,
	DISPLAY_NAME,
	ARMOR,
	HEALTH,
	MAXHEALTH,
	SHIELDS,
	MAXSHIELDS,
	ATTACK,
	RANGE,
	COST
}


onready var command_post_stats = {
	Stats.STRUCTURE_ID: StructureTypes.STRUCT_COMMAND_POST,
	Stats.DISPLAY_NAME: "Command Post",
	Stats.ARMOR: 10,
	Stats.MAXHEALTH: 1000,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 3,
	Stats.RANGE: 5,
	Stats.COST: {
		ResourceTypes.BIOMASS: 0,
		ResourceTypes.ALLOY: 400,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 100,
		ResourceTypes.COMMAND: 0}}

onready var biomass_reactor_stats = {
	Stats.STRUCTURE_ID: StructureTypes.STRUCT_BIOMASS_REACTOR,
	Stats.DISPLAY_NAME: "Biomass Reactor",
	Stats.ARMOR: 10,
	Stats.MAXHEALTH: 500,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 3,
	Stats.RANGE: 5,
	Stats.COST: {
		ResourceTypes.BIOMASS: 0,
		ResourceTypes.ALLOY: 100,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 0,
		ResourceTypes.COMMAND: 0}}

onready var alloy_foundry_stats = {
	Stats.STRUCTURE_ID: StructureTypes.STRUCT_ALLOY_FOUNDRY,
	Stats.DISPLAY_NAME: "Alloy Foundry",
	Stats.ARMOR: 10,
	Stats.MAXHEALTH: 500,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 0,
	Stats.RANGE: 0,
	Stats.COST: {
		ResourceTypes.BIOMASS: 0,
		ResourceTypes.ALLOY: 100,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 0,
		ResourceTypes.COMMAND: 0}}

onready var warpstone_refinery_stats = {
	Stats.STRUCTURE_ID: StructureTypes.STRUCT_WARPSTONE_REFINERY,
	Stats.DISPLAY_NAME: "Warpstone Refinery",
	Stats.ARMOR: 10,
	Stats.MAXHEALTH: 500,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 0,
	Stats.RANGE: 0,
	Stats.COST: {
		ResourceTypes.BIOMASS: 0,
		ResourceTypes.ALLOY: 100,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 0,
		ResourceTypes.COMMAND: 0}}

onready var energy_conduit_stats = {
	Stats.STRUCTURE_ID: StructureTypes.STRUCT_ENERGY_CONDUIT,
	Stats.DISPLAY_NAME: "Energy Conduit",
	Stats.ARMOR: 10,
	Stats.MAXHEALTH: 500,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 0,
	Stats.RANGE: 0,
	Stats.COST: {
		ResourceTypes.BIOMASS: 0,
		ResourceTypes.ALLOY: 200,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 0,
		ResourceTypes.COMMAND: 0}}

onready var statlines = {
	StructureTypes.STRUCT_COMMAND_POST: command_post_stats,
	StructureTypes.STRUCT_BIOMASS_REACTOR: biomass_reactor_stats,
	StructureTypes.STRUCT_ALLOY_FOUNDRY: alloy_foundry_stats,
	StructureTypes.STRUCT_WARPSTONE_REFINERY: warpstone_refinery_stats,
	StructureTypes.STRUCT_ENERGY_CONDUIT: energy_conduit_stats
}

onready var icons = {
	StructureTypes.STRUCT_COMMAND_POST: load("res://Assets/Art/Structures/imperium/command_post.png"),
	StructureTypes.STRUCT_BIOMASS_REACTOR: load("res://Assets/Art/Structures/imperium/biomass_reactor.png"),
	StructureTypes.STRUCT_ALLOY_FOUNDRY: load("res://Assets/Art/Structures/imperium/alloy_foundry.png"),
	StructureTypes.STRUCT_WARPSTONE_REFINERY: load("res://Assets/Art/Structures/imperium/warpstone_refinery.png"),
	StructureTypes.STRUCT_ENERGY_CONDUIT: load("res://Assets/Art/Structures/imperium/energy_conduit.png") 
}

onready var footprint = {
	StructureTypes.STRUCT_COMMAND_POST: Vector2(4, 4),
	StructureTypes.STRUCT_BIOMASS_REACTOR: Vector2(2, 2),
	StructureTypes.STRUCT_ALLOY_FOUNDRY: Vector2(2, 2),
	StructureTypes.STRUCT_WARPSTONE_REFINERY: Vector2(2, 2),
	StructureTypes.STRUCT_ENERGY_CONDUIT: Vector2(2, 2)
}

onready var build_options
onready var tech_options = {}

func set_module_refs():
	grid = get_tree().root.get_node("Main/GameMap/Grid")
	nav_map = get_tree().root.get_node("Main/Nav2D")
	structure_map = get_node("StructureMap")
	units = get_tree().root.get_node("Main/GameObjects/Units")
	res = get_tree().root.get_node("Main/GameObjects/Resources")

	build_options = {
		StructureTypes.STRUCT_COMMAND_POST: [
			units.UnitTypes.UNIT_TECHPRIEST]}

func add_structure(structure_type, coordinates):
	var new_structure = structure_scn.instance()
	$All.add_child(new_structure)
	new_structure.setup(structure_type, coordinates, $StructureMap.map_to_world(coordinates))
	# nav_map.update_nav_tile(coordinates, -1)
	# print(new_structure.get_footprint())
	# for each_tile in new_structure.get_footprint():
		# nav_map.add_tile_outline(each_tile)
	# var tile_coord = Vector2(new_structure.get_footprint()[0])
	# nav_map.add_tile_outline(tile_coord)
	
	grid.get_cell(coordinates).set_structure(statlines[structure_type][Stats.STRUCTURE_ID])
	grid.set_tiles_to_dirt(new_structure.get_footprint())
	# nav_map.add_collision_outline(new_structure)

func get_structures():
	return $All.get_children()

func get_width(structure_type):
	return footprint[structure_type].x

func get_height(structure_type):
	return footprint[structure_type].y

func get_footprint_tiles(structure_type, coordinates):
	var footprint_tiles = []
	var start = Vector2(coordinates)
	for y in range(footprint[structure_type].y):
		for x in range(footprint[structure_type].x):
			footprint_tiles.append(Vector2(start.x + x, start.y + y))

	return footprint_tiles

