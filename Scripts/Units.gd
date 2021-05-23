extends YSort

onready var unit_scn = preload("res://Scenes/Unit.tscn")
onready var creature_scn = preload("res://Scenes/Creature.tscn")
onready var worker_scn = preload("res://Scenes/Worker.tscn")
onready var soldier_scn = preload("res://Scenes/Soldier.tscn")
onready var vehicle_scn = preload("res://Scenes/Vehicle.tscn")
onready var tools = get_tree().root.get_node("Main/Tools")

var spriteframe_ref = {}
var faction
var build_cost = {}
var barrel_offsets = {}
var box_size
onready var thumbnail
onready var icons
var statlines = {}
func set_module_refs():
	load_stats()
	faction = {
		UnitTypes.UTYPE.MARINE: "imperium",
		UnitTypes.UTYPE.JOHNNY: "imperium",
		UnitTypes.UTYPE.TECHPRIEST: "imperium",
		UnitTypes.UTYPE.CONSCRIPT: "imperium",
		UnitTypes.UTYPE.CHICKEN: "gaia",
		UnitTypes.UTYPE.PREDATOR: "imperium",
		UnitTypes.UTYPE.RHINO: "imperium",
		UnitTypes.UTYPE.SENTINEL: "imperium",
		UnitTypes.UTYPE.LASCANNON: "imperium"
	}
	box_size = {
		UnitTypes.UTYPE.MARINE: "human",
		UnitTypes.UTYPE.TECHPRIEST: "human",
		UnitTypes.UTYPE.CONSCRIPT: "human",
		UnitTypes.UTYPE.CHICKEN: "human",
		UnitTypes.UTYPE.PREDATOR: "vehicle",
		UnitTypes.UTYPE.RHINO: "vehicle",
		UnitTypes.UTYPE.SENTINEL: "human",
		UnitTypes.UTYPE.LASCANNON: "vehicle"
	}
	thumbnail = {
		UnitTypes.UTYPE.MARINE: load("res://Assets/Art/Units/imperium/marine/icon.png"),
		UnitTypes.UTYPE.TECHPRIEST: load("res://Assets/Art/Units/imperium/techpriest/icon.png"),
		UnitTypes.UTYPE.CONSCRIPT: load("res://Assets/Art/Units/imperium/conscript/icon.png"),
		UnitTypes.UTYPE.LASCANNON: load("res://Assets/Art/Units/imperium/lascannon/icon.png"),
		UnitTypes.UTYPE.PREDATOR: load("res://Assets/Art/Units/imperium/predator/icon.png"),
		UnitTypes.UTYPE.RHINO: load("res://Assets/Art/Units/imperium/rhino/icon.png"),
		UnitTypes.UTYPE.SENTINEL: load("res://Assets/Art/Units/imperium/sentinel/icon.png"),
		UnitTypes.UTYPE.CHICKEN: load("res://Assets/Art/Units/gaia/space_chicken/icon.png")
	}

func load_stats():
	var file = File.new()
	file.open("res://dat/stats/stats.csv", file.READ)
	while !file.eof_reached():
		var csv = file.get_csv_line()
		
		if not csv[0] == "DISPLAY_NAME" and not csv[1] == "aa":

			statlines[UnitTypes.UTYPE[csv[1]]] = unpack_statline(csv)
	file.close()

func unpack_statline(statline):
	return {
		Stats.STAT.DISPLAY_NAME: statline[0],
		Stats.STAT.UNIT_ID: statline[1],
		Stats.STAT.HEALTH: int(statline[2]),
		Stats.STAT.MAXHEALTH: int(statline[2]),
		Stats.STAT.SHIELDS: int(statline[3]),
		Stats.STAT.MAXSHIELDS: int(statline[3]),
		Stats.STAT.ARMOR: int(statline[4]),
		Stats.STAT.ATTACK: int(statline[5]),
		Stats.STAT.RANGE: int(statline[6]),
		Stats.STAT.SIGHT: int(statline[7]),
		Stats.STAT.SPEED: int(statline[8]),
		Stats.STAT.BUILD_TIME: int(statline[9]),
		Stats.STAT.GATHER_TIME: int(statline[10]),
		Stats.STAT.CARRY_CAP: int(statline[11]),
		Stats.STAT.COST: {
			ResourceTypes.RES.ALLOY: int(statline[12]),
			ResourceTypes.RES.BIOMASS: int(statline[13]),
			ResourceTypes.RES.WARPSTONE: int(statline[14]),
			ResourceTypes.RES.ENERGY: int(statline[15]),
			ResourceTypes.RES.COMMAND: int(statline[16])}
	}

func unpack_barrel_offset(barrel_offset_line):
	var bol = barrel_offset_line
	return {
		"down": Vector2(bol[1], bol[2]),
		"down_left": Vector2(bol[3], bol[4]),
		"left": Vector2(bol[5], bol[6]),
		"up_left": Vector2(bol[7], bol[8]),
		"up": Vector2(bol[9], bol[10]),
		"up_right": Vector2(bol[11], bol[12]),
		"right": Vector2(bol[13], bol[14]),
		"down_right": Vector2(bol[15], bol[16])
	}



func load_barrel_offsets():
	var file = File.new()
	file.open("res://dat/unit_data/barrel_offsets.csv", file.READ)
	while !file.eof_reached():
		var csv = file.get_csv_line()
		if not csv[0] == "DISPLAY_NAME":
			barrel_offsets[UnitTypes.UTYPE[csv[1]]] = unpack_barrel_offset(csv)

	file.close()





func load_sprites():
	icons = {
		UnitTypes.UTYPE.MARINE: [],
		UnitTypes.UTYPE.TECHPRIEST: [],
		UnitTypes.UTYPE.RHINO: [],
		UnitTypes.UTYPE.PREDATOR: [],
		UnitTypes.UTYPE.CONSCRIPT: [],
		UnitTypes.UTYPE.LASCANNON: [],
		UnitTypes.UTYPE.CHICKEN: []
	}

	var faction_dir = "imperium/"
	var sprites_to_load = {
		UnitTypes.UTYPE.MARINE: "marine/",
		UnitTypes.UTYPE.TECHPRIEST: "techpriest/",
		UnitTypes.UTYPE.CONSCRIPT: "conscript/",
		UnitTypes.UTYPE.LASCANNON: "lascannon/",
		UnitTypes.UTYPE.PREDATOR: "predator/",
		UnitTypes.UTYPE.SENTINEL: "sentinel/",
		UnitTypes.UTYPE.RHINO: "rhino/"
	}

	for unit_type in sprites_to_load.keys():
		load_unit_sprites(faction_dir, unit_type, sprites_to_load[unit_type])

	faction_dir = "gaia/"
	sprites_to_load = {
		UnitTypes.UNIT_CHICKEN: "space_chicken/"
	}

	for unit_type in sprites_to_load.keys():
		load_unit_sprites(faction_dir, unit_type, sprites_to_load[unit_type])
		

func load_unit_sprites(faction_dir, unit_type, unit_dir):
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

func add_unit(player_owner, unit_type, location, target_location=null):
	var new_unit
	if unit_type == UnitTypes.UTYPE.CHICKEN:
		new_unit = creature_scn.instance()
	elif unit_type == UnitTypes.UTYPE.TECHPRIEST:
		new_unit = worker_scn.instance()
	elif unit_type == UnitTypes.UTYPE.CONSCRIPT:
		new_unit = soldier_scn.instance()
	elif unit_type == UnitTypes.UTYPE.PREDATOR:
		new_unit = vehicle_scn.instance()
	else:
		new_unit = unit_scn.instance()
	add_child(new_unit)
	new_unit.setup(player_owner, unit_type, location)
	if target_location:
		new_unit.move_to(target_location)

func get_build_time(unit_type):
	return statlines[unit_type][Stats.STAT.BUILD_TIME]

func get_build_cost(unit_type):
	return statlines[unit_type][Stats.STAT.COST]

func get_display_name(unit_type):
	return statlines[unit_type][Stats.STAT.DISPLAY_NAME]

func get_faction(unit_type):
	return faction[unit_type]

func check_target(old_target):
	if has_node(old_target.get_path()):
		return true
	return false

func load_animations(spriteframe, unit):
	var unit_path = (
		"res://Assets/Art/Units/" +
		get_faction(unit).to_lower().replace(" ", "_") + "/" +
		get_display_name(unit).to_lower().replace(" ", "_"))
	var directions = [
		"down",
		"down_right",
		"right",
		"up_right",
		"up",
		"up_left",
		"left",
		"down_left"
		]
	var base_actions = [
		"idle",
		"walk",
		"windup",
		"attack_idle",
		"attack",
		"dying",
		"rot"
		]
	var gatherer_units = [UnitTypes.UTYPE.TECHPRIEST]
	var gatherer_actions = [
		"construct",
		"extract_tree",
		"extract_ore",
		"extract_crystal",
		"extract_chicken"]
	var unit_actions = base_actions
	if unit in gatherer_units:
		unit_actions += gatherer_actions

	for action in unit_actions:
		var action_path = unit_path + "/" + action
		for direction in directions:
			var sprites_path = action_path + "/" + direction + "/"
			var anim_name = direction + "_" + action
			spriteframe.add_animation(anim_name)
			
			for img_file in tools.list_files_in_directory(sprites_path):

				if img_file.ends_with(".import"): continue
				spriteframe.add_frame(anim_name, load(sprites_path + img_file))
			spriteframe.set_animation_speed(anim_name, 30)
			spriteframe.set_animation_loop(anim_name, false)
			if action == "walk" or action == "attack_idle":
				spriteframe.set_animation_loop(anim_name, true)

func get_weapon_type(unit_type):
	if unit_type == UnitTypes.UTYPE.PREDATOR or unit_type == UnitTypes.UTYPE.LASCANNON:
		return Types.WEAPON.BEAM
	return Types.WEAPON.PROJECTILE

func spriteframe_warmup():
	print("Starting Spriteframe Warmup...")
	var start = OS.get_unix_time()
	for unit in UnitTypes.UTYPE:
		var spriteframe_path = (
			"res://Assets/SpriteFrames/Units/" +
			get_faction(UnitTypes.UTYPE[unit]).to_lower().replace(" ", "_") +
			"/" +
			get_display_name(UnitTypes.UTYPE[unit]).to_lower().replace(" ", "_") +
			"/SpriteFrame.tres")
		var unit_spriteframe = load(spriteframe_path)
		spriteframe_ref[UnitTypes.UTYPE[unit]] = unit_spriteframe
	print("... complete: " + str(OS.get_unix_time() - start))

func build_spriteframes():
	for unit in UnitTypes.UTYPE:
		var spriteframe_path = (
			"res://Assets/SpriteFrames/Units/" +
			get_faction(UnitTypes.UTYPE[unit]).to_lower().replace(" ", "_") +
			"/" +
			get_display_name(UnitTypes.UTYPE[unit]).to_lower().replace(" ", "_") +
			"/SpriteFrame.tres")
		var unit_spriteframe = load(spriteframe_path)
		unit_spriteframe.clear_all()
		load_animations(unit_spriteframe, UnitTypes.UTYPE[unit])
		ResourceSaver.save(spriteframe_path, unit_spriteframe)
