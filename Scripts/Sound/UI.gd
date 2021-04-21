extends Node2D
var tools
var units


var unit_spawns
var unit_greetings
var unit_confirmations
var unit_deaths


onready var engineer_greetings = [
	$EngineerSelect2
]
onready var techpriest_greetings = [
	$EngineerSelect2
]

onready var marine_greetings = [$MarineSelect1]

onready var conscript_greetings = [
	$Conscript/Select1,
	$Conscript/Select2,
	$Conscript/Select3,
	$Conscript/Select4
]
onready var conscript_confirms = [
	$Conscript/Confirm1,
	$Conscript/Confirm2,
	$Conscript/Confirm3,
	$Conscript/Confirm4,
	$Conscript/Move1,
	$Conscript/Move2
]

onready var engineer_confirms = []
onready var marine_confirms = []

func _ready():
	tools = get_tree().root.get_node("Main/Tools")
	units = get_tree().root.get_node("Main//GameObjects/Units")
	
	unit_greetings = {
		units.UnitTypes.UNIT_ENGINEER: engineer_greetings,
		units.UnitTypes.UNIT_TECHPRIEST: techpriest_greetings,
		units.UnitTypes.UNIT_CONSCRIPT: conscript_greetings,
		units.UnitTypes.UNIT_MARINE: marine_greetings
	}

	
	unit_confirmations = {
		units.UnitTypes.UNIT_ENGINEER: conscript_confirms,
		units.UnitTypes.UNIT_TECHPRIEST: conscript_confirms,
		units.UnitTypes.UNIT_CONSCRIPT: conscript_confirms,
		units.UnitTypes.UNIT_MARINE: conscript_confirms
	}

func _on_BuildMenu_play_tick_1():
	$Tick1.play()

func _on_Dispatcher_unit_selected(unit):
	if not "utype" in unit: return
	tools.r_choice(unit_greetings[unit.utype]).play()


func _on_Dispatcher_unit_spawned(unit):
	$MarineSpawn.play()



func _on_Dispatcher_unit_confirm(unit):
	tools.r_choice(unit_confirmations[unit.utype]).play()


func _on_Dispatcher_set_rally_point():
	$SetRallyPoint.play()


func _on_ConstructionMenu_play_tick_1():
	$Tick1.play()


func _on_Dispatcher_resource_selected(resource):
	$Tick2.play()
