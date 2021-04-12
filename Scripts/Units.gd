extends Node2D

onready var unit_scn = preload("res://Scenes/Unit.tscn")
onready var gatherer_scn = preload("res://Scenes/Gatherer.tscn")


var base_stats = {
	"display name": "placeholder",
	"speed": 0,
	"maxhealth": 0,
	"attack": 0,
	"range": 0,
	"armor": 0,
	"build time": 0,
	"carry cap": 0,
	"cost": {"Biomass": 0, "Alloy": 0, "Warpstone": 0, "Energy": 0}}


var marine_stats = {
	"display name": "Johnny Space",
	"speed": 60,
	"armor": 3,
	"maxhealth": 150,
	"attack": 12,
	"range": 6,
	"build time": 12,
	"cost": {"Biomass": 60, "Alloy": 30, "Warpstone": 0, "Energy": 0}}

var engineer_stats = {
	"display name": "Engineer",
	"speed": 30,
	"armor": 0,
	"maxhealth": 30,
	"attack": 0,
	"range": 0,
	"build time": 5,
	"carry cap": 10,
	"gather time": 1,
	"cost": {"Biomass": 50, "Alloy": 0, "Warpstone": 0, "Energy": 0}}

var conscript_stats = {
	"display name": "Conscript",
	"speed": 30,
	"armor": 1,
	"maxhealth": 40,
	"attack": 5,
	"range": 3,
	"build time": 10,
	"cost": {"Biomass": 50, "Alloy": 0, "Warpstone": 0, "Energy": 5}}

var lascannon_stats = {
	"display name": "Lascannon",
	"speed": 15,
	"armor": 0,
	"maxhealth": 80,
	"attack": 30,
	"range": 18,
	"build time": 12,
	"cost": {"Biomass": 0, "Alloy": 600, "Warpstone": 0, "Energy": 100}}

var rhino_stats = {
	"display name": "Rhino",
	"speed": 60,
	"armor": 10,
	"maxhealth": 1000,
	"attack": 50,
	"range": 9,
	"build time": 15,
	"cost": {"Biomass": 0, "Alloy": 600, "Warpstone": 0, "Energy": 100}}

var build_cost = {}

var box_size = {
	"Marine": "human",
	"Engineer": "human",
	"Conscript": "human",
	"Lascannon": "vehicle",
	"Rhino": "vehicle"}

var statlines = {
	"Base": base_stats,
	"Marine": marine_stats,
	"Engineer": engineer_stats,
	"Conscript": conscript_stats,
	"Lascannon": lascannon_stats,
	"Rhino": rhino_stats}

var icons = {
	"Marine": [
		load("res://Assets/Art/spess.png"),
		load("res://Assets/Art/spess.png"),
		load("res://Assets/Art/spess.png"),
		load("res://Assets/Art/spess.png"),
		load("res://Assets/Art/spess.png"),
		load("res://Assets/Art/spess.png"),
		load("res://Assets/Art/spess.png"),
		load("res://Assets/Art/spess.png")],
	"Engineer": [
		load("res://Assets/Art/Units/engineer/up.png"),
		load("res://Assets/Art/Units/engineer/up_right.png"),
		load("res://Assets/Art/Units/engineer/right.png"),
		load("res://Assets/Art/Units/engineer/down_right.png"),
		load("res://Assets/Art/Units/engineer/down.png"),
		load("res://Assets/Art/Units/engineer/down_left.png"),
		load("res://Assets/Art/Units/engineer/left.png"),
		load("res://Assets/Art/Units/engineer/up_left.png")],
	"Lascannon": [
		load("res://Assets/Art/Units/lascannon/up.png"),
		load("res://Assets/Art/Units/lascannon/up_right.png"),
		load("res://Assets/Art/Units/lascannon/right.png"),
		load("res://Assets/Art/Units/lascannon/down_right.png"),
		load("res://Assets/Art/Units/lascannon/down.png"),
		load("res://Assets/Art/Units/lascannon/down_left.png"),
		load("res://Assets/Art/Units/lascannon/left.png"),
		load("res://Assets/Art/Units/lascannon/up_left.png")],
	"Rhino": [
		load("res://Assets/Art/Units/rhino/up.png"),
		load("res://Assets/Art/Units/rhino/up_right.png"),
		load("res://Assets/Art/Units/rhino/right.png"),
		load("res://Assets/Art/Units/rhino/down_right.png"),
		load("res://Assets/Art/Units/rhino/down.png"),
		load("res://Assets/Art/Units/rhino/down_left.png"),
		load("res://Assets/Art/Units/rhino/left.png"),
		load("res://Assets/Art/Units/rhino/up_left.png")]
	}

func _ready():
	for each_unit in statlines.keys():
		build_cost[each_unit] = statlines[each_unit]["cost"]


func add_unit(unit_type, location):
	var new_unit = null
	if unit_type == "Engineer":
		new_unit = gatherer_scn.instance()
	else:
		new_unit = unit_scn.instance()
	add_child(new_unit)
	new_unit.load_stats(unit_type)
	new_unit.position = location
	new_unit.zero_target()

