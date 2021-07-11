extends Node2D
signal exploration_changed

onready var main = get_tree().root.get_node("Main")
onready var grid = main.get_node("GameMap/Grid")
onready var x
onready var y
onready var base
onready var resource
onready var resource_id
onready var structure
onready var structure_id
onready var _explored = {}

func initialize():
	set_base(-1)
	set_resource_id(-1)
	set_structure_id(-1)
	self.connect("exploration_changed", grid, "_on_Cell_exploration_changed")

func initialize_exploration():
	for each_player in main.players.keys():
		_explored[each_player] = false

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

func set_explored(player_number, is_explored):
	_explored[player_number] = is_explored
	emit_signal("exploration_changed", player_number)

func get_explored(player_number): return _explored[player_number]
