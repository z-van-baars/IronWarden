extends "res://Scripts/HumanPlayer.gd"
# LOCAL HUMAN PLAYER

onready var dragging = false
onready var spawn_mode = get_tree().root.get_node("Main").spawn_mode
onready var _shift = false
onready var _ctrl = false


func set_local(is_local):
	_is_local = is_local
	if is_local:
		get_node("Camera2D").current = true

func _unhandled_input(event):
	if not chatbox_cooldown.is_stopped(): return
	if event.is_action_pressed("esc"):
		emit_signal("escape_key_pressed")
	if event.is_action_pressed("~"):
		emit_signal("toggle_debug_menu")
	if event.is_action_pressed("ui_accept"):
		emit_signal("enter_key_pressed")
	if event.is_action_pressed("ui_space"):
		if _selected_units != []:
			$Camera2D.center_on_coordinates(_selected_units[0].get_center())
	if event.is_action_pressed("spawn_mode"):
		spawn_mode = true
		emit_signal("toggle_spawn_mode")
	if event.is_action_released("spawn_mode"):
		spawn_mode = false
		emit_signal("toggle_spawn_mode")
	if event.is_action_pressed("K_shift"): _shift = true
	if event.is_action_released("K_shift"): _shift = false
	if event.is_action_pressed("K_ctrl"): _ctrl = true
	if event.is_action_pressed("K_ctrl"): _ctrl = false
	if event.is_action_pressed("K_h"):
		if not _cps.empty():
			clear_selected()
			var index = 0
			if _selected_units[0] in _cps and _cps.size() > 1:
				index = tools.index_wrap(
					_cps,
					_cps.find(_selected_units[0]) + 1)

			_selected_units = _cps[index]
			_selected_units[0].select()
			
	if event.is_action_pressed("left_click"):
		clear_selected()
		if not construction_mode:
			selection_box.start_box(
				get_viewport().get_canvas_transform().xform_inv(get_viewport().get_mouse_position()))
			return

		if grid.construction_site_clear(
			grid.get_tile(get_global_mouse_position()), construction_build_id):
			emit_signal("new_construction", get_player_number(), construction_build_id, grid.get_tile(get_global_mouse_position()))
			debit_resources(st.get_cost(construction_build_id))
			var selected_constructors = get_constructors(_selected_units)
			for constructor in selected_constructors:
				constructor.set_build_target(grid.get_tile(get_global_mouse_position()))
			return

	if event.is_action_released("left_click"):
		selection_box.close_box()

		if spawn_mode == true:
			var new_unit = unit_scn.instance()
			units.add_child(new_unit)
			new_unit.position = get_viewport().get_canvas_transform().xform_inv(get_viewport().get_mouse_position())
			new_unit.load_stats("Rhino")

	if event.is_action_pressed("right_click") and !_selected_units.empty():
		if construction_mode: 
			emit_signal("construction_mode_right_clicked")
			return
		var click_loc = get_viewport().get_canvas_transform().xform_inv(event.position * $Camera2D._zoom_level)
		_selected_units[0].play_move_confirm()
		emit_signal("unit_move_to", click_loc)
		if _selected_units.size() == 1:
			_selected_units[0].player_right_clicked(get_player_number(), click_loc, _shift)
			return

		var unit_positions = []
		var average_pos
		var total_moving_units = 0
		var total_x = 0
		var total_y = 0
		for each in _selected_units:
			unit_positions.append(each.get_world_pos())
			if _selected_units[0].has_method("can_path") and _selected_units[0].can_path():
				total_moving_units += 1
				total_x += each.get_world_pos().x
				total_y += each.get_world_pos().y
		average_pos = Vector2(total_x, total_y) / total_moving_units

		var formation = tools.get_formation(
			click_loc,
			unit_positions,
			20,
			click_loc.angle_to_point(average_pos))
		var pos_number = 0
		for formation_position in formation:
			if !_selected_units[0].has_method("can_path") and !_selected_units[0].can_path():
				continue
			_selected_units[pos_number].player_right_clicked(
				get_player_number(), formation_position + click_loc, _shift)

			pos_number += 1

func _on_Selection_Box_end(newly_selected):
	clear_selected()
	if newly_selected.empty(): return
	var selected_structures = []
	var selected_non_structures = []
	for each in newly_selected:
		if each.has_method("get_footprint"):
			selected_structures.append(each)
		else:
			selected_non_structures.append(each)
	if not selected_non_structures.empty():
		for each in selected_non_structures:
			_selected_units.append(each)
			each.select()
	else:
		for each in selected_structures:
			_selected_units.append(each)
			each.select()
	_selected_units[0].play_greeting()
	emit_signal("unit_selected", _selected_units[0])


func select_all_onscreen(unit):
	_selected_units = [unit]
	for each_unit in _selected_units:
		each_unit.select()
	_selected_units[0].play_greeting()


func _on_Dispatcher_deposit_right_click(deposit):
	if _selected_units.empty(): return
	if !gatherers_selected(): return
	var gatherer_units = []
	for each_unit in _selected_units:
		if each_unit.has_method("can_gather") and each_unit.can_gather():
			gatherer_units.append(each_unit)

	for gatherer in gatherer_units:
		gatherer.gather(deposit)
		deposit.gather_target_set(gatherer)


func _on_Dispatcher_resource_left_click(deposit):
	clear_selected()
	last_clicked = deposit
	_selected_units = [deposit]
	deposit.select()
	emit_signal("deposit_selected", deposit)


func _on_Dispatcher_unit_left_clicked(unit):
	#doubleclick select all goes here
	if $DoubleClickTimer.is_stopped() == false and last_clicked == unit:
		select_all_onscreen(unit)
		emit_signal("unit_selected", _selected_units[0])
		return
	last_clicked = unit
	$DoubleClickTimer.start()
	_selected_units = [unit]
	unit.select()
	if unit.get_player_number() == get_player_number():
		unit.play_greeting()
	emit_signal("unit_selected", unit)


func _on_Dispatcher_unit_right_clicked(unit):
	if unit.get_player_number() == get_player_number(): return
	if _selected_units.empty(): return
	
	for each in _selected_units:
		if each.get_player_number() != get_player_number(): continue
		each.set_target_unit(unit)

func on_start(tile_map):
	$Camera2D.center_on_tile(tile_map, get_base().get_tile_coords())
