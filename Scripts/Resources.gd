extends Node2D

onready var grid
onready var st
onready var tools
onready var nav_map = get_tree().root.get_node("Main/Nav2D")
onready var deposit_scn = preload("res://Scenes/Deposit.tscn")

onready var crystal_deposit
onready var ore_deposit
onready var tree
onready var dropoff_types
onready var deposits
onready var deposit_name_string
onready var tile_ids
onready var icons
onready var deposit_icons
onready var thumbnail


func string_from_id(resource_id):
	var resource_strings = {
		0: "Biomass",
		1: "Alloy",
		2: "Warpstone",
		3: "Energy",
		4: "Command"
	}
	return resource_strings[resource_id]


func set_module_refs():
	crystal_deposit = {ResourceTypes.RES.WARPSTONE: 50}
	ore_deposit = {ResourceTypes.RES.ALLOY: 100}
	tree = {ResourceTypes.RES.BIOMASS: 100}
	deposits = {
		DepositTypes.DEPOSIT.CRYSTAL: crystal_deposit,
		DepositTypes.DEPOSIT.ORE: ore_deposit,
		DepositTypes.DEPOSIT.TREE: tree}
	deposit_name_string = {
		DepositTypes.DEPOSIT.CRYSTAL: "Crystal Deposit",
		DepositTypes.DEPOSIT.ORE: "Ore Deposit",
		DepositTypes.DEPOSIT.TREE: "Tree"
	}
	tile_ids = {
		DepositTypes.DEPOSIT.CRYSTAL: 0,
		DepositTypes.DEPOSIT.ORE: 1,
		DepositTypes.DEPOSIT.TREE: 2
	}
	thumbnail = {
		DepositTypes.DEPOSIT.CRYSTAL: load("res://Assets/Art/Units/imperium/marine/icon.png"),
		DepositTypes.DEPOSIT.ORE: load("res://Assets/Art/Units/imperium/marine/icon.png"),
		DepositTypes.DEPOSIT.TREE: load("res://Assets/Art/Units/imperium/marine/icon.png")
	}

	grid = get_tree().root.get_node("Main/GameMap/Grid")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	tools = get_tree().root.get_node("Main/Tools")
	load_images()
	set_dropoff_types()

func load_images():
	icons = {
		ResourceTypes.RES.BIOMASS: 
			load("res://Assets/Art/UI/Icons/Resources/32/biomass.png"),
		ResourceTypes.RES.ALLOY: 
			load("res://Assets/Art/UI/Icons/Resources/32/alloy.png"),
		ResourceTypes.RES.WARPSTONE: 
			load("res://Assets/Art/UI/Icons/Resources/32/warpstone.png"),
		ResourceTypes.RES.ENERGY:
			load("res://Assets/Art/UI/Icons/Resources/32/energy.png"),
		ResourceTypes.RES.COMMAND:
			load("res://Assets/Art/UI/Icons/Resources/32/command.png")}
	

	deposit_icons = {
		DepositTypes.DEPOSIT.CRYSTAL: [],
		DepositTypes.DEPOSIT.ORE: [],
		DepositTypes.DEPOSIT.TREE: [],
		DepositTypes.DEPOSIT.VENT: []
	}
	var paths = {
		DepositTypes.DEPOSIT.CRYSTAL: "crystal/",
		DepositTypes.DEPOSIT.ORE: "ore/",
		DepositTypes.DEPOSIT.TREE: "tree/",
		DepositTypes.DEPOSIT.VENT: "vent/"}
	
	for dtype in deposit_icons.keys():
		collect_icons(dtype, paths[dtype])
	
func collect_icons(deposit_type, path_string):
	var resource_path = "res://Assets/Art/Resources/"
	for each in tools.list_files_in_directory(resource_path + path_string):
		if each.ends_with(".png"):
			deposit_icons[deposit_type].append(load(resource_path + path_string + each))


func set_dropoff_types():
	dropoff_types = {
		ResourceTypes.RES.BIOMASS: [
			StructureTypes.STRUCT.COMMAND_POST,
			StructureTypes.STRUCT.BIOMASS_REACTOR],
		ResourceTypes.RES.ALLOY: [
			StructureTypes.STRUCT.COMMAND_POST,
			StructureTypes.STRUCT.ALLOY_FOUNDRY],
		ResourceTypes.RES.WARPSTONE: [
			StructureTypes.STRUCT.COMMAND_POST,
			StructureTypes.STRUCT.WARPSTONE_REFINERY],
		ResourceTypes.RES.ENERGY: [
			StructureTypes.STRUCT.COMMAND_POST,
			StructureTypes.STRUCT.ENERGY_CONDUIT],
		ResourceTypes.RES.COMMAND: [
			StructureTypes.STRUCT.COMMAND_POST]}

func get_display_name(deposit_type):
	return deposit_name_string[deposit_type]

func add_deposit(deposit_type, coordinates):
	# Coordinates are MAP coordinates: Vector2(int, int)
	var new_deposit = deposit_scn.instance()
	$Deposits.add_child(new_deposit)
	new_deposit.setup(deposit_type, coordinates, $ResourceMap.map_to_world(coordinates))
	grid.set_resource(coordinates, deposit_type)

	grid.set_tiles_to_dirt([coordinates])
	# nav_map.add_tile_outline(coordinates)
	# nav_map.add_collision_outline(new_deposit)

func get_r_type(deposit_type):
	return deposits[deposit_type].keys()[0]


