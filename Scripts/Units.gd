extends Node2D

onready var unit_scn = preload("res://Scenes/Unit.tscn")
onready var builder_scn = preload("res://Scenes/Builder.tscn")
onready var marine_scn = preload("res://Scenes/Marine.tscn")

enum UnitTypes {
	UNIT_MARINE,
	UNIT_ENGINEER,
	UNIT_TECHPRIEST,
	UNIT_RHINO,
	UNIT_CONSCRIPT,
	UNIT_LASCANNON
}

enum ResourceTypes {
	BIOMASS,
	ALLOY,
	WARPSTONE,
	ENERGY,
	COMMAND
}

enum Stats {
	UNIT_ID,
	DISPLAY_NAME,
	SPEED,
	ARMOR,
	HEALTH,
	MAXHEALTH,
	SHIELDS,
	MAXSHIELDS,
	ATTACK,
	RANGE,
	BUILD_TIME,
	GATHER_TIME,
	CARRY_CAP,
	COST
}

var marine_stats = {
	Stats.UNIT_ID: UnitTypes.UNIT_MARINE,
	Stats.DISPLAY_NAME: "Johnny Space",
	Stats.SPEED: 30,
	Stats.ARMOR: 3,
	Stats.MAXHEALTH: 150,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 12,
	Stats.RANGE: 6,
	Stats.BUILD_TIME: 10,
	Stats.GATHER_TIME: 0,
	Stats.CARRY_CAP: 0,
	Stats.COST: {
		ResourceTypes.BIOMASS: 0,
		ResourceTypes.ALLOY: 0,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 0,
		ResourceTypes.COMMAND: 0}
}

var engineer_stats = {
	Stats.UNIT_ID: UnitTypes.UNIT_ENGINEER,
	Stats.DISPLAY_NAME: "Engineer",
	Stats.SPEED: 20,
	Stats.ARMOR: 0,
	Stats.MAXHEALTH: 30,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 0,
	Stats.RANGE: 0,
	Stats.BUILD_TIME: 5,
	Stats.GATHER_TIME: 1.5,
	Stats.CARRY_CAP: 10,
	Stats.COST: {
		ResourceTypes.BIOMASS: 50,
		ResourceTypes.ALLOY: 0,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 0,
		ResourceTypes.COMMAND: 0}
}
	

var techpriest_stats = {
	Stats.UNIT_ID: UnitTypes.UNIT_TECHPRIEST,
	Stats.DISPLAY_NAME: "Techpriest",
	Stats.SPEED: 20,
	Stats.ARMOR: 0,
	Stats.MAXHEALTH: 30,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 0,
	Stats.RANGE: 0,
	Stats.BUILD_TIME: 5,
	Stats.GATHER_TIME: 1.5,
	Stats.CARRY_CAP: 10,
	Stats.COST: {
		ResourceTypes.BIOMASS: 50,
		ResourceTypes.ALLOY: 0,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 0,
		ResourceTypes.COMMAND: 0}
}

var conscript_stats = {
	Stats.UNIT_ID: UnitTypes.UNIT_CONSCRIPT,
	Stats.DISPLAY_NAME: "Conscript",
	Stats.SPEED: 20,
	Stats.ARMOR: 1,
	Stats.MAXHEALTH: 40,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 5,
	Stats.RANGE: 3,
	Stats.BUILD_TIME: 5,
	Stats.GATHER_TIME: 0,
	Stats.CARRY_CAP: 0,
	Stats.COST: {
		ResourceTypes.BIOMASS: 50,
		ResourceTypes.ALLOY: 0,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 5,
		ResourceTypes.COMMAND: 0}
}


var lascannon_stats = {
	Stats.UNIT_ID: UnitTypes.UNIT_LASCANNON,
	Stats.DISPLAY_NAME: "Lascannon",
	Stats.SPEED: 15,
	Stats.ARMOR: 0,
	Stats.MAXHEALTH: 75,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 30,
	Stats.RANGE: 18,
	Stats.BUILD_TIME: 12,
	Stats.GATHER_TIME: 0,
	Stats.CARRY_CAP: 0,
	Stats.COST: {
		ResourceTypes.BIOMASS: 0,
		ResourceTypes.ALLOY: 200,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 100,
		ResourceTypes.COMMAND: 0}
}

var rhino_stats = {
	Stats.UNIT_ID: UnitTypes.UNIT_RHINO,
	Stats.DISPLAY_NAME: "Rhino",
	Stats.SPEED: 60,
	Stats.ARMOR: 10,
	Stats.MAXHEALTH: 1000,
	Stats.MAXSHIELDS: 0,
	Stats.ATTACK: 50,
	Stats.RANGE: 9,
	Stats.BUILD_TIME: 15,
	Stats.GATHER_TIME: 0,
	Stats.CARRY_CAP: 0,
	Stats.COST: {
		ResourceTypes.BIOMASS: 0,
		ResourceTypes.ALLOY: 600,
		ResourceTypes.WARPSTONE: 0,
		ResourceTypes.ENERGY: 100,
		ResourceTypes.COMMAND: 0}
}

var build_cost = {}

var box_size = {
	UnitTypes.UNIT_MARINE: "human",
	UnitTypes.UNIT_ENGINEER: "human",
	UnitTypes.UNIT_TECHPRIEST: "human",
	UnitTypes.UNIT_CONSCRIPT: "human",
	UnitTypes.UNIT_RHINO: "vehicle",
	UnitTypes.UNIT_LASCANNON: "vehicle"}

var statlines = {
	UnitTypes.UNIT_MARINE: marine_stats,
	UnitTypes.UNIT_ENGINEER: engineer_stats,
	UnitTypes.UNIT_TECHPRIEST: techpriest_stats,
	UnitTypes.UNIT_CONSCRIPT: conscript_stats,
	UnitTypes.UNIT_LASCANNON: lascannon_stats,
	UnitTypes.UNIT_RHINO: rhino_stats}

onready var icons

func _ready():
	for each_unit in statlines.keys():
		build_cost[each_unit] = statlines[each_unit][Stats.COST]
	load_sprites()


func load_sprites():
	icons = {
		UnitTypes.UNIT_MARINE: [],
		UnitTypes.UNIT_ENGINEER: [],
		UnitTypes.UNIT_TECHPRIEST: [],
		UnitTypes.UNIT_RHINO: [],
		UnitTypes.UNIT_CONSCRIPT: [],
		UnitTypes.UNIT_LASCANNON: []
	}

	var faction_dir = "imperium/"
	var sprites_to_load = {
		UnitTypes.UNIT_MARINE: "marine/",
		UnitTypes.UNIT_ENGINEER: "engineer/",
		UnitTypes.UNIT_TECHPRIEST: "techpriest/",
		UnitTypes.UNIT_CONSCRIPT: "conscript/",
		UnitTypes.UNIT_LASCANNON: "lascannon/",
		UnitTypes.UNIT_RHINO: "rhino/"
	}

	for unit_type in sprites_to_load.keys():
		load_unit_sprites(faction_dir, unit_type, sprites_to_load[unit_type])
		

func load_unit_sprites(faction_dir, unit_type, unit_dir):
	# this is the syntax when a unit unpacks the sprites
	#$UpSprite.texture = _icon_list[0]
	#$UpRightSprite.texture = _icon_list[1]
	#$RightSprite.texture = _icon_list[2]
	#$DownRightSprite.texture = _icon_list[3]
	#$DownSprite.texture = _icon_list[4]
	#$DownLeftSprite.texture = _icon_list[5]
	#$LeftSprite.texture = _icon_list[6]
	#$UpLeftSprite.texture = _icon_list[7]

	var _dir = "res://Assets/Art/Units/"
	var directions = [
		"up",
		"up_right",
		"right",
		"down_right",
		"down",
		"down_left",
		"left",
		"up_left"
	]

	for direction_str in directions:
		var file_str = _dir + faction_dir + unit_dir + direction_str + ".png"
		icons[unit_type].append(load(file_str))

func set_module_refs():
	pass

func add_unit(unit_type, location, target_location=null):
	var new_unit
	if unit_type == UnitTypes.UNIT_TECHPRIEST:
		new_unit = builder_scn.instance()
	elif unit_type == UnitTypes.UNIT_MARINE:
		new_unit = marine_scn.instance()
	else:
		new_unit = unit_scn.instance()
	add_child(new_unit)
	new_unit.setup(unit_type, location)
	if target_location != null:
		new_unit.path_to(target_location)

func get_build_time(unit_type):
	return statlines[unit_type][Stats.BUILD_TIME]

func get_build_cost(unit_type):
	return statlines[unit_type][Stats.COST]

func get_display_name(unit_type):
	return statlines[unit_type][Stats.DISPLAY_NAME]

