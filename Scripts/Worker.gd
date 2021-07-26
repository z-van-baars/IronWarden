extends "res://Scripts/MotileUnit.gd"
var gather_started = false
var gather_radius = 50

func can_construct(): return true

func can_gather(): return true

func set_task_gather():
	task = Tasks.GATHER
	clear_target_unit()
	clear_target_construction()
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


func start_construct():
	set_state_construct()
	zero_target()
	$ConstructionTimer.start(get_construction_time())

func gather(target_deposit):
	set_target_deposit(target_deposit)
	set_task_gather()
	play_sound(Sounds.GATHER_CONFIRM)

func _draw():
	$Target.hide()
	if not selected: return
	if not get_tree().root.get_node("Main").draw_paths: return
	if not path.empty():
		var path_pts = []
		path_pts.append(position - position)
		path_pts.append(step_target - position)
		for each_point in path:
			path_pts.append(each_point - position)
		draw_polyline(path_pts, Color.red, 3)
	if final_target != null and final_target != position:
		# $Target.show()
		$Target.position = final_target - position

	if target_deposit != null and selected == true:
		target_deposit.get_node("SelectionBox").show()
		target_deposit.get_node("SelectionBox").modulate = Color.green

func _on_Target_Deposit_exhausted():
	target_deposit = null
	if state == States.EXTRACT:
		set_state_move()
		path_to(target_dropoff.get_center())
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
			path_to(target_deposit.get_center())
			set_state_move()
		else:
			if path.size() <= 0: # do we have a path?
				path_to(target_dropoff.get_center())
				set_state_move()
			return

	# is cargo less-than full?
	if not check_contact(target_deposit): return

	# have we started gathering already?
	if state == States.EXTRACT: return

	start_gather() # if not, start

func find_dropoff_target():
	var structures_to_sort = []
	for each_structure in st.get_structures():
		if each_structure.get_stype() in res.dropoff_types[target_deposit.get_r_type()]:
			structures_to_sort.append(each_structure)
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
	pickup_resource(gather_type, target_deposit.increment(gather_type, 1))
	play_sound(Sounds.EXTRACT, target_deposit.get_id())
	$ResourceCollectionLabel.show()
	$ResourceCollectionLabel/Icon/ResourceIcon.texture = res.icons[gather_type]
	$ResourceCollectionLabel/QuantityLabel.text = "+ 1 "
	$ResourceCollectionLabel/AnimationPlayer.play("Extract")
	emit_signal("update", self)
	$GatherTimer.start(get_gather_time())

func _on_ConstructionTimer_timeout():
	target_construction.increment()
	play_sound(Sounds.CONSTRUCT)
	$ConstructionTimer.start(get_gather_time())




func _on_AnimationPlayer_animation_finished(anim_name):
	$ResourceCollectionLabel.hide()
