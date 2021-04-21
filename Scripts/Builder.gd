extends "res://Scripts/Unit.gd"
var carrying = {}

var target_dropoff = null
var target_resource = null
var gather_type = null
var gather_started = false
var gather_radius = 50

	
func set_task_gather():
	task = Tasks.TASK_GATHER

func set_state_extract():
	$Hammer.show()
	$Hammer/AnimationPlayer.play("swing")
	state = States.STATE_EXTRACT

func set_state_idle():
	state = States.STATE_IDLE
	if target_resource != null:
		target_resource.gather_target_unset(self)
		target_resource = null
	$Hammer.hide()
	$Hammer/AnimationPlayer.stop()

func set_state_move():
	state = States.STATE_MOVE
	$Hammer.hide()
	$Hammer/AnimationPlayer.stop()


func start_gather():
	set_state_extract()
	zero_target()
	$GatherTimer.wait_time = get_gather_time()
	$GatherTimer.start()

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

func deselect():
	selected = false
	$SelectionBox.hide()
	$HealthBar.hide()
	if target_resource: target_resource.get_node("SelectionBox").hide()

func _on_Target_Resource_kill():
	target_resource = null
	if state == States.STATE_EXTRACT:
		set_state_move()
		path_to(target_dropoff.get_center())
	elif state == States.STATE_MOVE and carrying[gather_type] == 0:
		set_state_idle()
		set_task_idle()
		zero_target()

func empty_lading():
	carrying = {
		res.ResourceTypes.BIOMASS: 0,
		res.ResourceTypes.ALLOY: 0,
		res.ResourceTypes.WARPSTONE: 0,
		res.ResourceTypes.ENERGY: 0}
	

func get_carried(gather_type):
	return carrying[gather_type]

func gather_task_logic():
	# is cargo full
	if get_carried(gather_type) >= get_carry_cap():
		$GatherTimer.stop()
		# do we have a drop-off point?
		if target_dropoff == null: target_dropoff = find_dropoff_target()
		assert(target_dropoff != null)
		# are we far from drop-off point?
		if tools.v_distance(target_dropoff.get_center(), get_center()) > gather_radius:
			# do we have a path?
			if path.size() <= 0:
				path_to(target_dropoff.get_center())
				set_state_move()
			# are we colliding with the base area?
			if check_contact(target_dropoff):
				# drop-off resources
				player.credit_resources(carrying)
				empty_lading()
				# switch state - return to resource
				path_to(target_resource.get_center())
				set_state_move()
			return

		# are we at drop-off point?
		elif tools.v_distance(target_dropoff.get_center(), get_center()) <= gather_radius:
			# drop-off resources
			player.credit_resources(carrying)
			empty_lading()
			# switch state - return to resource
			path_to(target_resource.get_center())
			set_state_move()

	
	# is cargo less-than full
	# are we at the resource target?
	if tools.v_distance(target_resource.get_center(), get_center()) >= gather_radius: return

	# have we started gathering already?
	if state == States.STATE_EXTRACT: return

	# if not, start
	start_gather()

func _process(delta):
	match task:
		Tasks.TASK_GATHER:
			gather_task_logic()
		Tasks.TASK_IDLE:
			return
	update()


func _physics_process(delta):
	match state:
		States.STATE_IDLE:

			return
		States.STATE_MOVE:

			if position == final_target:
				if task == Tasks.TASK_IDLE:
					set_state_idle()
				elif task == Tasks.TASK_GATHER:
					set_state_extract()
				elif task == Tasks.TASK_ATTACK_TARGET:
					set_state_attack()
				
			# Do we have a path with at least 1 point remaining?
			if path.size() > 0:
				if position.distance_to(step_target) < 5:
					step_target = path[0]
					path.remove(0)
			else:
				step_target = final_target
				if position.distance_to(final_target) < 5:
					zero_target()
					set_state_idle()

	direction = (step_target - position).normalized()
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()

	# move and junk
	var movement = get_speed() * direction * delta
	move_and_collide(movement)
	
	# set animation / sprite based on last direction modulo current direction
	if direction != last_direction:
		get_facing()
	last_direction = direction

func set_resource_target(resource):
	if target_resource: target_resource.get_node("SelectionBox").hide()
	target_resource = resource
	gather_type = resource.r_type
	path_to(resource.get_center())
	confirm()



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

func pickup_resource(gather_type, quantity):
	carrying[gather_type] += quantity

func _on_GatherTimer_timeout():
	target_resource.increment(gather_type, 1)
	pickup_resource(gather_type, 1)
	tools.r_choice([
		$HammerTink1,
		$HammerTink2,
		$HammerTink3,
		$HammerTink4,
		$HammerTink5]).play()
	emit_signal("update", self)
	$GatherTimer.wait_time = get_gather_time()
	$GatherTimer.start()


