extends Node

onready var _unit_positions : Dictionary
onready var _unit_count : int
onready var _average_pos : Vector2
onready var _waypoints : Array
onready var _headcount : int
onready var _stance = null
onready var _ranks : int
onready var _columns : int
onready var signal_count : int

func setup(initial_units):
	set_units(initial_units)
	calculate_properties()
	signal_count = 0

func set_units(initial_units):
	_unit_count = initial_units.size()

	for unit in initial_units:
		_unit_positions[unit] = null
		unit.set_formation(self)

func calculate_properties():
	if all_units().empty():
		queue_free()
		return
	var size_float = float(all_units().size())
	_columns = max(4, ceil(size_float / 3.0))
	_ranks = ceil(size_float / float(_columns))
	set_center()
	set_raw_positions()

func remove_unit(unit):
	_unit_positions.erase(unit)
	set_units(all_units())
	calculate_properties()
	 
func all_units():
	return _unit_positions.keys()

func get_center():
	return _average_pos

func set_center():
	var n_positions = 0
	var total = Vector2.ZERO
	for each in all_units():
		n_positions += 1
		total += each.get_world_pos()
	_average_pos = total / n_positions

func set_raw_positions():
	var u_width = all_units()[0].get_footprint().shape.radius * 5
	var u_radius = u_width / 2.0
	var u_height = u_width / 1.75
	u_width = u_height
	# later on maybe make this average unit radius, right now just 1st * 5
	# in theory this should be derivative based on average unit size, since smaller units
	# would need a tighter formation than larger ones, but its a decent starting point

	var current_position = Vector2.ZERO
	current_position.x = -(_columns / 2.0) * u_width + u_radius
	# rank iteration counter, int
	var _count = 0
	for _rr in range(_ranks):
		for _cc in range(_columns):
			if _count >= all_units().size():
				return
			_unit_positions[all_units()[_count]] = current_position
			_count += 1
			current_position.x += u_width
		if all_units().size() - _count < _columns:
			current_position.x = -(all_units().size() - _count) / 2.0 * u_width
		else:
			current_position.x = -(_columns / 2.0) * u_width
		current_position += Vector2(u_radius, u_height)

func get_destination():
	return _waypoints.back()

func add_waypoint(location):
	_waypoints.append(location)

func add_waypoint_by_unit(waypoint, shift):
	var avg_last = Vector2.ZERO
	for unit in all_units():
		if not unit.waypoints.empty():
			avg_last += unit.get_last_waypoint()
		else:
			avg_last += get_center()
	avg_last /= _unit_count
	var destination_positions = get_unit_positions(waypoint, avg_last)
	for unit in all_units():
		unit.player_right_clicked(
			unit.get_player_number(),
			destination_positions[unit],
			shift)

func get_previous_waypoint():
	if _waypoints.size() == 1:
		return get_center()
	return _waypoints[-2]

func get_last_waypoint():
	return _waypoints.back()

func get_first_waypoint():
	return _waypoints.front()

func get_next_waypoint():
	# could maybe be renamed to "trim_first_waypoint()"
	return _waypoints.pop_front()

func clear_waypoints():
	_waypoints = []

func _on_Unit_waypoint_reached():
	signal_count += 1
	_headcount += 1
	if _headcount < _unit_count:
		return
	_headcount = 0
	get_next_waypoint()

func _on_Player_right_click(click_location, shift):
	calculate_properties()

	add_waypoint_by_unit(click_location, shift)


func get_unit_positions(waypoint, last_location):
	var rotation_radians = (last_location.angle_to_point(waypoint))
	var rotated_positions = get_rotated_positions(rotation_radians)
	var final_positions = {}
	for unit in all_units():
		var de_biased_position = rotated_positions[unit] * Vector2(1.75, 1)
		final_positions[unit] = de_biased_position + waypoint
	return final_positions

func get_rotated_positions(rotation_radians):
	var positions_rotated = {}
	for each in _unit_positions.keys():
		var angled_pos = _unit_positions[each].rotated(rotation_radians)
		angled_pos = angled_pos.rotated(-1.5708)

		positions_rotated[each] = angled_pos
	return positions_rotated



