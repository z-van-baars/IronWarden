extends Node2D
var x
var y
var base
var resource
var structure


func initialize():
	x = null
	y = null
	set_base(-1)
	set_resource(-1)
	set_structure(-1)



func set_pos(coordinates):
	x = coordinates.x
	y = coordinates.y

func get_pos():
	return Vector2(x, y)

func set_base(base_type):
	base = base_type

func get_base():
	return base

func set_resource(resource_type):
	resource = resource_type

func get_resource():
	return resource

func set_structure(structure_type):
	structure = structure_type

func get_structure():
	return structure

func is_walkable():
	return (
		(base == 0 or base == 1)
		and resource == -1
		and structure == -1)

func is_buildable():
	return (
		(base == 0 or base == 1)
		and resource == -1
		and structure == -1)
