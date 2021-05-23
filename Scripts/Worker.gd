extends "res://Scripts/Unit.gd"
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
	$Hammer.show()
	$Hammer/AnimationPlayer.play("hammer_swing")
	$GatherTimer.start(get_gather_time())
	state = States.EXTRACT
	state_changed()

func additional_idle_functions():
	if target_resource != null:
		clear_target_resource()

	$Hammer.hide()
	$Hammer/AnimationPlayer.stop()


func additional_move_functions():
	$Hammer.hide()
	$Hammer/AnimationPlayer.stop()

func start_gather():
	set_state_extract()
	zero_target()


func start_construct():
	set_state_construct()
	zero_target()
	$ConstructionTimer.start(get_construction_time())

func gather(target_deposit):
	set_target_resource(target_deposit)
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

	if target_resource != null and selected == true:
		target_resource.get_node("SelectionBox").show()

func _on_Target_Resource_kill():
	target_resource = null
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

func gather_task_logic():
	# is cargo full
	if get_carried(gather_type) >= get_carry_cap():
		$GatherTimer.stop()
		# do we have a drop-off point?
		if target_dropoff == null: target_dropoff = find_dropoff_target()
		assert(target_dropoff != null)
		# are we at drop-off point?
		if check_contact(target_dropoff):
			# drop-off resources
			credit_resources()
			empty_lading()
			# switch state - return to resource
			path_to(target_resource.get_center())
			set_state_move()
		# are we far from drop-off point?
		else:
		
			# do we have a path?
			if path.size() <= 0:
				path_to(target_dropoff.get_center())
				set_state_move()
			# are we colliding with the base area?
			if check_contact(target_dropoff):
				# drop-off resources
				credit_resources()
				empty_lading()
				# switch state - return to resource
				path_to(target_resource.get_center())
				set_state_move()
			return

	# is cargo less-than full
	# are we at the resource target?
	if not check_contact(target_resource): return

	# have we started gathering already?
	if state == States.EXTRACT: return

	# if not, start
	start_gather()

func find_dropoff_target():
	var structures_to_sort = []
	for each_structure in structures.get_structures():
		if each_structure.stype in res.dropoff_types[target_resource.r_type]:
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
	target_resource.increment(gather_type, 1)
	pickup_resource(gather_type, 1)
	play_sound(Sounds.EXTRACT, target_resource.d_type)
	emit_signal("update", self)
	$GatherTimer.start(get_gather_time())
	$Hammer/AnimationPlayer.stop()
	$Hammer/AnimationPlayer.play()

func _on_ConstructionTimer_timeout():
	target_construction.increment()
	play_sound(Sounds.CONSTRUCT)
	$ConstructionTimer.start(get_gather_time())


