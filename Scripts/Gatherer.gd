extends "res://Scripts/Unit.gd"

enum Tasks {
	TASK_IDLE,
	TASK_GATHER
}

enum States {
	STATE_MOVE,
	STATE_ATTACK,
	STATE_EXTRACT,
	STATE_IDLE
}

var carrying = {
	"Biomass": 0,
	"Alloy": 0,
	"Warpstone": 0,
	"Energy": 0}

var target_dropoff = null
var target_resource = null
var gather_type = null
var gather_started = false

func _draw():
	$Target.hide()
	if selected == true:
		if path.size() > 0 and get_tree().root.get_node("Main").draw_paths == true:
			var path_pts = []
			path_pts.append(position - position)
			path_pts.append(step_target - position)
			for each_point in path:
				path_pts.append(each_point - position)
			draw_polyline(path_pts, Color.red, 3)
		if final_target != null and final_target != position:
			$Target.show()
			$Target.position = final_target - position
	
	if target_resource != null and selected == true:
		target_resource.get_node("$Border").show()

func empty_lading():
	carrying = {
		"Biomass": 0,
		"Alloy": 0,
		"Warpstone": 0,
		"Energy": 0}

func gather_task_logic():
	# is cargo full
	if carrying[gather_type] >= carry_cap:
		# are we far from drop-off point?
		if tools.distance_to(target_dropoff.get_center()) > 10:
			# do we have a path?
			if path.size() <= 0:
				path_to(target_dropoff)
				state = States.STATE_MOVE

		# are we at drop-off point?
		elif tools.distance_to(target_dropoff.get_center()) <= 16:
			# drop-off resources
			player.credit_resources(carrying)
			empty_lading()
			# switch state - return to resource
			state = States.STATE_MOVE
	
	# is cargo less-than full
	else:
		# are we at the resource target?
		if tools.distance_to(Vector2(target_resource)) > 5:
			# have we started gathering already?
			if not gather_started: start_gather()
			return
		else:
			pass
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
					state = States.STATE_IDLE
				elif task == Tasks.TASK_GATHER:
					state = States.STATE_EXTRACT
				elif task == Tasks.TASK_ATTACK_TARGET:
					state = States.STATE_ATTACK
				
			# Do we have a path with at least 1 point remaining?
			if path.size() > 0:
				if position.distance_to(step_target) < 5:
					step_target = path[0]
					path.remove(0)
			else:
				step_target = final_target
				if position.distance_to(final_target) < 5:
					zero_target()

	direction = (step_target - position).normalized()
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()

	# move and junk
	var movement = speed * direction * delta
	move_and_collide(movement)
	
	# set animation / sprite based on last direction modulo current direction
	if direction != last_direction:
		get_facing()
	
	last_direction = direction



func start_gather():
	$GatherTimer.wait_time = gather_time
	$GatherTimer.start()


func set_resource_target(resource):
	target_resource = resource
	path_to(resource.get_center())
	task = Tasks.TASK_GATHER

func find_dropoff_target():
	var structures_to_sort = []
	for each_structure in structures.get_children():
		if each_structure.display_name in res.dropoff_types[target_resource.r_type]:
			structures_to_sort.append(each_structure)
	
	var distance_to = {}
	for unmeasured in structures_to_sort:
		tools.get_distance(unmeasured.get_center(), get_center())
	
	var closest_structure = null
	var closest_distance = 999999
	
	for _ss in distance_to.keys():
		if distance_to[_ss] < closest_distance:
			closest_structure = _ss
			closest_distance = distance_to[_ss]
	return closest_structure


func _on_GatherTimer_timeout():
	target_resource.increment(gather_type, 1)
	carrying[gather_type] += 1
	$GatherTimer.wait_time = gather_time
	$GatherTimer.start()
