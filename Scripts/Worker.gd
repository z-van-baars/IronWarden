extends "res://Scripts/MotileUnit.gd"
var gather_quantity = 1

func can_construct(): return true

func can_gather(): return true

func set_task(task_type, task_target):
	match task_type:
		TaskQueue.Type.Construct:
			set_target_construction(task_target)
		TaskQueue.Type.Extract:
			gather(task_target)
			task_target.gather_target_set(self)

func set_task_gather():
	task = Tasks.GATHER
	clear_target_unit()
	clear_target_construction()
	task_changed()

func set_task_construct():
	task = Tasks.CONSTRUCT_STRUCTURE
	clear_target_unit()
	clear_target_deposit()
	task_changed()

func set_state_extract():
	$AnimatedSprite.set_animation(animation_direction + "_idle")
	$AnimatedSprite.play()
	$GatherTimer.start(get_gather_time())
	state = States.EXTRACT
	state_changed()

func additional_idle_functions():
	if target_deposit != null:
		clear_target_deposit()


func additional_move_functions():
	pass

func start_gather():
	set_state_extract()
	zero_target()

func set_target_construction(new_target_construction):
	assert(new_target_construction != null)
	clear_target_construction()
	target_construction = new_target_construction
	target_construction.connect_construction_signal(self)
	set_task_construct()
	path_to_object(target_construction)
	set_state_move()

func clear_target_construction():
	if not target_construction: return
	target_construction.disconnect_construction_signal(self)
	target_construction = null

func _on_TargetConstruction_finished():
	if not task_queue.queue.empty():
		set_task_idle()
		set_state_idle()
		zero_target()
		return
	var nearby_sites = find_nearby_construction_sites()
	if nearby_sites.empty():
		set_task_idle()
		set_state_idle()
		zero_target()
		return
		
	var new_target = sort_nearby_construction_sites(nearby_sites)
	set_target_construction(new_target.get_coordinates())

func sort_nearby_construction_sites(site_array):
	assert(!site_array.empty())
	return site_array[0]

func start_construction():
	set_state_construct()
	zero_target()

func find_nearby_construction_sites():
	var nearby_sites = []
	return nearby_sites

func gather(target_deposit):
	set_target_deposit(target_deposit)
	set_task_gather()
	play_sound(Sounds.GATHER_CONFIRM)

func _draw():
	$Target.hide()
	if not selected: return
	# passthrough
	if get_tree().root.get_node("Main").draw_targets():
		if final_target != null and final_target != position:
			$Target.show()
			$Target.position = final_target - position
		for alt_target in alternative_targets:
			draw_circle(alt_target - position, 5, Color(1.0, 0.5, 0.5, 0.5))
		var last_waypoint = final_target
		for waypoint in waypoints:
			if waypoint != final_target:
				draw_circle(waypoint - position, 5, Color(1.0, 0.85, 0.25, 0.5))
				draw_polyline([last_waypoint - position, waypoint - position], Color(0.0, 0.85, 0.70, 0.4), 2)
			last_waypoint = waypoint
		# passthrough
	if not get_tree().root.get_node("Main").draw_paths(): return

	var path_pts = []
	path_pts.append(position - position)
	path_pts.append(step_target - position)
	for each_point in path:
		path_pts.append(each_point - position)
	draw_polyline(path_pts, Color(0.0, 1.0, 0.75, 0.5), 3)

	if target_deposit != null and selected == true:
		target_deposit.get_node("SelectionBorder").show()
		target_deposit.get_node("SelectionBorder").modulate = Color.green
	if alternative_targets.empty():
		return

func _on_Target_Deposit_exhausted():
	target_deposit = null
	if state == States.EXTRACT:
		path_to_object(target_dropoff)
		set_state_move()

	elif state == States.MOVE and carrying[gather_type] == 0:
		set_state_idle()
		set_task_idle()
		zero_target()

func empty_lading():
	carrying = {
		ResourceTypes.RES.BIOMASS: 0,
		ResourceTypes.RES.ALLOY: 0,
		ResourceTypes.RES.WARPSTONE: 0,
		ResourceTypes.RES.ENERGY: 0}
	

func get_carried(g_type):
	return carrying[g_type]

func find_nearby_deposit_target():
	return map_grid.find_nearby_deposits(position, 10, extraction_type)

func gather_task_logic():
	if target_deposit == null:
		target_deposit = map_grid.get_deposit(find_nearby_deposit_target())
	if target_dropoff == null:
		target_dropoff = find_dropoff_target()
	if target_deposit == null and target_dropoff == null:
		set_state_idle()
		set_task_idle()
		zero_target()
		return

	# is cargo full
	if get_carried(gather_type) >= get_carry_cap():
		$GatherTimer.stop()
		# are we at the drop-off point?
		if check_contact(target_dropoff):
			credit_resources()
			empty_lading()
			path_to_object(target_deposit)
			set_state_move()
			return
		else:
			if position == final_target:
				path_to_object(target_dropoff)
				set_state_move()
				return

	# is cargo less-than full?
	if not check_contact(target_deposit):
		return

	# have we started gathering already?
	if state == States.EXTRACT: return

	start_gather() # if not, start

func find_dropoff_target():
	var structures_to_sort = []
	for each_structure in st.get_structures():
		if each_structure.get_stype() in res.dropoff_types[target_deposit.get_r_type()]:
			structures_to_sort.append(each_structure)
	if structures_to_sort.empty():
		return null
	return tools.r_choice(structures_to_sort)

	var distance_to = {}
	for unmeasured in structures_to_sort:
		tools.distance(
			unmeasured.get_center().x,
			unmeasured.get_center().y,
			get_center().x,
			get_center().y)
	
	var closest_structure = null
	var closest_distance = 999999
	
	for _ss in distance_to.keys():
		if distance_to[_ss] < closest_distance:
			closest_structure = _ss
			closest_distance = distance_to[_ss]
	return closest_structure

func pickup_resource(g_type, quantity):
	carrying[g_type] += quantity

func credit_resources():
	emit_signal("credit_resources", carrying, get_player_number())

func debit_resources(debit_amount):
	emit_signal("debit_resources", debit_amount, get_player_number())

func _on_GatherTimer_timeout():
	pickup_resource(gather_type, target_deposit.increment(gather_type, gather_quantity))
	play_sound(Sounds.EXTRACT, target_deposit.get_id())
	$ResourceCollectionLabel.show()
	$ResourceCollectionLabel/Icon/ResourceIcon.texture = res.icons[gather_type]
	$ResourceCollectionLabel/QuantityLabel.text = "+ " + str(gather_quantity)
	$ResourceCollectionLabel/AnimationPlayer.play("Extract")
	emit_signal("update", self)
	$GatherTimer.start(get_gather_time())

func construct_task_logic():
	if target_construction == null:
		set_state_idle()
		set_task_idle()
		zero_target()
		return

	# are we at the construction site?
	if not check_contact(target_construction):
		if position == final_target: # do we have a path?
			path_to_object(target_construction)
			set_state_move()
		return

	# have we started construction already?
	if state == States.CONSTRUCT: return
	start_construction() # if not, start

func _on_ConstructionTimer_timeout():
	$ConstructionTimer.start()
	target_construction.increment_construction()
	play_sound(Sounds.CONSTRUCT)
	


func _on_AnimationPlayer_animation_finished(anim_name):
	$ResourceCollectionLabel.hide()
