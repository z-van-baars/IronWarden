extends Node
var formation_scn = load("res://Scripts/Formation.gd")


func get_new_formation(component_units):
	var new_formation = formation_scn.new()
	new_formation.setup(component_units)
	return new_formation
