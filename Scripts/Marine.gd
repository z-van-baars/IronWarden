extends "res://Scripts/Unit.gd"

func load_stats(unit_type):
	var _stats = units.statlines[unit_type]
	utype = unit_type

	$SelectionBox.texture = selection_border_size[units.box_size[unit_type]]

func _physics_process(delta):
	set_frame()
	if position == final_target:
		return
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
	var movement = get_speed() * direction * delta
	move_and_collide(movement)
	
	# set animation / sprite based on last direction modulo current direction
	if direction != last_direction:
		get_facing()
	
	last_direction = direction


func zero_target():
	final_target = position
	direction = Vector2(0, 0)
	path = []
	step_target = position

func set_frame():
	if position == final_target or position.distance_to(final_target) <= 5 or direction == Vector2(0, 0):
		for sprite in directional_sprites.values():
			sprite.set_frame(0)
			sprite.stop()
		return
	for sprite in directional_sprites.values():
		sprite.play("walk")





