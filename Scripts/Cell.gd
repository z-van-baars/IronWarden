extends Node2D
var x
var y
var base
var resource
var resource_id
var structure
var structure_id

var explored = false setget set_explored


func initialize():
	x = null
	y = null
	set_base(-1)
	set_resource_id(-1)
	set_structure_id(-1)

func set_pos(coordinates):
	x = coordinates.x
	y = coordinates.y

func get_pos():
	return Vector2(x, y)

func get_x():
	return x

func get_y():
	return y

func set_base(base_type):
	base = base_type

func get_base():
	return base

func set_resource_id(resource_type):
	resource_id = resource_type

func get_resource_id():
	return resource_id

func set_structure_id(structure_type):
	structure_id = structure_type

func get_structure_id():
	return structure_id

func set_structure(structure_obj):
	structure = structure_obj

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
		and resource_id == -1
		and structure_id == -1)

func set_explored(is_explored): explored = is_explored
func get_explored(): return explored
