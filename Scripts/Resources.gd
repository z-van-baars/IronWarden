extends Node2D

onready var grid
onready var st
onready var tools
onready var nav_map = get_tree().root.get_node("Main/Nav2D")
onready var resource_scn = preload("res://Scenes/Resource.tscn")

enum ResourceTypes {
	BIOMASS,
	ALLOY,
	WARPSTONE,
	ENERGY,
	COMMAND
}

enum DepositTypes {
	ORE,
	GEM,
	VENT,
	TREE,
	SPACE_CHICKEN
}



onready var dropoff_types

onready var gem_deposit = {
	ResourceTypes.WARPSTONE: 50}
onready var ore_deposit = {
	ResourceTypes.ALLOY: 100}
onready var tree = {
	ResourceTypes.BIOMASS: 100}
onready var space_chicken = {
	ResourceTypes.BIOMASS: 50}

onready var deposits = {
	DepositTypes.GEM: gem_deposit,
	DepositTypes.ORE: ore_deposit,
	DepositTypes.TREE: tree,
	DepositTypes.SPACE_CHICKEN: space_chicken}

onready var deposit_name_string = {
	DepositTypes.GEM: "Gem Deposit",
	DepositTypes.ORE: "Ore Deposit",
	DepositTypes.TREE: "Tree",
	DepositTypes.SPACE_CHICKEN: "Space Chicken"}

onready var tile_ids = {
	DepositTypes.GEM: 0,
	DepositTypes.ORE: 1,
	DepositTypes.TREE: 2,
	DepositTypes.SPACE_CHICKEN: 4}

onready var icons

onready var deposit_icons

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
	grid = get_tree().root.get_node("Main/GameMap/Grid")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	tools = get_tree().root.get_node("Main/Tools")
	load_images()
	set_dropoff_types()


func load_images():
	icons = {
		ResourceTypes.BIOMASS: 
			load("res://Assets/Art/UI/Icons/Resources/biomass.png"),
		ResourceTypes.ALLOY: 
			load("res://Assets/Art/UI/Icons/Resources/alloy.png"),
		ResourceTypes.WARPSTONE: 
			load("res://Assets/Art/UI/Icons/Resources/minerals_alt.png"),
		ResourceTypes.ENERGY:
			load("res://Assets/Art/UI/Icons/Resources/energy.png"),
		ResourceTypes.COMMAND:
			load("res://Assets/Art/UI/Icons/Resources/alloy.png")}
	
	var resource_dir = "res://Assets/Art/Resources/"
	deposit_icons = {
		DepositTypes.GEM: [],
		DepositTypes.ORE: [],
		DepositTypes.TREE: [],
		DepositTypes.VENT: [],
		DepositTypes.SPACE_CHICKEN: []}
	
	for each in tools.list_files_in_directory(resource_dir + "gem/"):
		if each.substr(each.length() - 4) == ".png":
			deposit_icons[DepositTypes.GEM].append(load(resource_dir + "gem/" + each))
	for each in tools.list_files_in_directory(resource_dir + "ore/"):
		if each.substr(each.length() - 4) == ".png":
			deposit_icons[DepositTypes.ORE].append(load(resource_dir + "ore/" + each))
	for each in tools.list_files_in_directory(resource_dir + "tree/"):
		if each.substr(each.length() - 4) == ".png":
			deposit_icons[DepositTypes.TREE].append(load(resource_dir + "tree/" + each))
	for each in tools.list_files_in_directory(resource_dir + "vent/"):
		if each.substr(each.length() - 4) == ".png":
			deposit_icons[DepositTypes.VENT].append(load(resource_dir + "vent/" + each))
	deposit_icons[DepositTypes.SPACE_CHICKEN].append(load("res://Assets/Art/Creatures/space_chicken.png"))

func set_dropoff_types():
	dropoff_types = {
		ResourceTypes.BIOMASS: [
			st.StructureTypes.STRUCT_COMMAND_POST,
			st.StructureTypes.STRUCT_BIOMASS_REACTOR],
		ResourceTypes.ALLOY: [
			st.StructureTypes.STRUCT_COMMAND_POST,
			st.StructureTypes.STRUCT_ALLOY_FOUNDRY],
		ResourceTypes.WARPSTONE: [
			st.StructureTypes.STRUCT_COMMAND_POST,
			st.StructureTypes.STRUCT_WARPSTONE_REFINERY],
		ResourceTypes.ENERGY: [
			st.StructureTypes.STRUCT_COMMAND_POST,
			st.StructureTypes.STRUCT_ENERGY_CONDUIT],
		ResourceTypes.COMMAND: [
			st.StructureTypes.STRUCT_COMMAND_POST]}

func get_display_name(deposit_type):
	return deposit_name_string[deposit_type]

func add_deposit(deposit_type, coordinates):
	# Coordinates are MAP coordinates, whole numbers and tile address
	var new_deposit = resource_scn.instance()
	$Deposits.add_child(new_deposit)
	new_deposit.setup(deposit_type, coordinates, $ResourceMap.map_to_world(coordinates))
	grid.set_resource(coordinates, tile_ids[deposit_type])
	grid.set_tiles_to_dirt([coordinates])
	# nav_map.add_tile_outline(coordinates)
	# nav_map.add_collision_outline(new_deposit)

func get_r_type(deposit_type):
	return deposits[deposit_type].keys()[0]


