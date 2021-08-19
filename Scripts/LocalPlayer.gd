extends "res://Scripts/HumanPlayer.gd"
# LOCAL HUMAN PLAYER

onready var dragging = false
onready var spawn_mode = get_tree().root.get_node("Main").spawn_mode()
onready var _shift = false
onready var _ctrl = false

onready var _formations = []


func set_local(is_local):
	_is_local = is_local
	if is_local:
		get_node("Camera2D").current = true

func get_shift():
	return _shift

func _unhandled_input(event):
	if not chatbox_cooldown.is_stopped(): return
	if event.is_action_pressed("esc"):
		emit_signal("escape_key_pressed")
	if event.is_action_pressed("ui_tilde"):
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
	if event.is_action_pressed("ui_delete"):
		if _selected_units.empty():
			return
		var unowned = []
		var to_delete = []
		for s_unit in _selected_units:
			if s_unit.get_player_number() == get_player_number():
				to_delete.append(s_unit)
			else:
				unowned.append(s_unit)
		for each in to_delete:
			each.kill()
			each.deselect()
		_selected_units = unowned
		emit_signal("selection_cleared")
		if not _selected_units.empty():
			emit_signal("units_selected", _selected_units)
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
		var global_click_location = get_global_mouse_position()
		if not construction_mode or construction_build_id == null:
			if not _shift:
				clear_selected()
			selection_box.start_box(
				get_viewport().get_canvas_transform().xform_inv(get_viewport().get_mouse_position()))
			return
		if not grid.construction_site_clear(
			grid.get_tile(global_click_location), construction_build_id, get_player_number()):
			emit_signal("deny")
		else:
			var tile_coords = grid.get_tile(global_click_location)
			emit_signal(
				"new_construction",
				construction_build_id,
				tile_coords,
				get_player_number())
			emit_signal("zoinks")
			var new_construction = grid.get_structure_at(global_click_location)

			emit_signal("set_target_location", global_click_location)
			debit_resources(st.get_cost(construction_build_id))
			var selected_constructors = get_selected_constructors(_selected_units)
			for constructor in selected_constructors:
				constructor.set_target_construction(new_construction)
			if not _shift:
				emit_signal("construction_mode_cancel", construction_build_id)
		
				

	if event.is_action_released("left_click"):
		if not construction_mode:
			selection_box.close_box()

	if event.is_action_pressed("right_click") and !_selected_units.empty():
		var owned_units = filter_owned(_selected_units, get_player_number())
		if owned_units.empty():
			return
		if construction_mode:
			emit_signal("construction_mode_cancel", construction_build_id)
			return
		var click_location = get_viewport().get_canvas_transform().xform_inv(event.position * $Camera2D._zoom_level)

		var motile_units = []
		var production_structures = []

		for each in owned_units:
			if each.has_method("can_path") and each.can_path():
				motile_units.append(each)
			if not each.build_options.empty():
				production_structures.append(each)
		if not owned_units.empty():
			emit_signal("set_target_location", click_location)
			owned_units[0].play_move_confirm()
		if not motile_units.empty():
			for each in motile_units:
				each.clear_formation()
				if motile_units.size() == 1:
					each.player_right_clicked(get_player_number(), click_location, _shift)
					return
			var new_formation = FormTools.get_new_formation(motile_units)
			new_formation._on_Player_right_click(click_location, _shift)
			# _formations.append(new_formation)
		if not production_structures.empty():
			for each in production_structures:
				each.player_right_clicked(get_player_number(), click_location, false)
		


func _on_Selection_Box_end(newly_selected):
	if not _shift:
		clear_selected()
	if newly_selected.empty(): return
	var owned_units = filter_owned(newly_selected, get_player_number())
	var new_motile_units = []
	var new_structures = []
	var new_units = []
	for each in owned_units:
		if each.has_method("increment_construction"):
			new_structures.append(each)
		else:
			new_motile_units.append(each)
	
	if not new_motile_units.empty():
		for each in new_motile_units:
			_selected_units.append(each)
			each.select()
	else:
		for each in new_structures:
			_selected_units.append(each)
			each.select()
	new_units = new_motile_units + new_structures
	
	if not new_units.empty():
		new_units[0].play_greeting()
		emit_signal("units_selected", _selected_units)


func select_all_onscreen(unit):
	_selected_units = [unit]
	for each_unit in _selected_units:
		each_unit.select()
	_selected_units[0].play_greeting()

func _on_Dispatcher_reform_button_pressed():
	if _selected_units.size() == 1:
		return
	var motile_units = []
	for each in _selected_units:
		if each.has_method("can_path") and each.can_path():
			motile_units.append(each)
	for each in motile_units:
		each.clear_formation()
	var new_formation = FormTools.get_new_formation(motile_units)
	new_formation._on_Player_right_click(new_formation.get_center(), _shift)

func _on_Dispatcher_remove_selected(unit_array):
	for unit in unit_array:
		_selected_units.erase(unit)

func _on_Dispatcher_deposit_right_clicked(deposit):
	if _selected_units.empty(): return
	if !gatherers_selected(): return
	var gatherer_units = []
	for each_unit in _selected_units:
		if each_unit.has_method("can_gather") and each_unit.can_gather():
			gatherer_units.append(each_unit)

	for gatherer in gatherer_units:
		gatherer.gather(deposit)
		deposit.gather_target_set(gatherer)


func _on_Dispatcher_deposit_left_clicked(deposit):
	if construction_mode == true:
		return
	clear_selected()
	last_clicked = deposit
	_selected_units = [deposit]
	deposit.select()
	emit_signal("units_selected", _selected_units)


func _on_Dispatcher_unit_left_clicked(unit):
	#doubleclick select all goes here
	if $DoubleClickTimer.is_stopped() == false and last_clicked == unit:
		select_all_onscreen(unit)
		emit_signal("units_selected", _selected_units)
		return
	if construction_mode == true:
		return
	last_clicked = unit
	$DoubleClickTimer.start()
	_selected_units.append(unit)
	unit.select()

	if (unit.get_player_number() == get_player_number() or
		unit.get_player_number() == -1):
		unit.play_greeting()
	emit_signal("units_selected", _selected_units)


func _on_Dispatcher_unit_right_clicked(unit):
	if _selected_units.empty(): return
	if (construction_mode == true
		and construction_build_id != null): return
	var owned = unit.get_player_number() == get_player_number()
	if !unit.can_path():
		if owned and unit.get_constructed():
			return
		elif owned and !unit.get_constructed():
			var constructors = get_selected_constructors(_selected_units)
			if not constructors.empty():
				for each in constructors:
					each.set_target_construction(unit)
	if owned:
		return

	for each in filter_owned(_selected_units, get_player_number()):
		each.set_target_unit(unit)

func on_start(tile_map):
	$Camera2D.center_on_tile(tile_map, get_base().get_coordinates())
