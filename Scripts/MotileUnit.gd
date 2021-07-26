extends "res://Scripts/GameUnit.gd"

enum Tasks {
	IDLE,
	MOVE_TO_LOCATION,
	GATHER,
	ATTACK_TARGET,
	CONSTRUCT_STRUCTURE,
	DIE,
	ROT
}

enum States {
	MOVE,
	ATTACK,
	EXTRACT,
	CONSTRUCT,
	IDLE,
	DYING,
	DEAD
}

func setup(unit_type, location, player_owner):
	set_module_refs()
	connect_signals()
	load_stats(unit_type)
	_player_owner = player_owner
	position = location
	last_direction = Vector2(
		tools.rng.randf_range(0.0, 1.0),
		tools.rng.randf_range(0.0, 1.0)).normalized()
	set_faction(units.get_faction(unit_type))
	set_spriteframes(units.get_faction(unit_type), unit_type)
	set_detection_polygon()
	build_sounds()
	zero_target()
	set_task_idle()
	set_state_idle()

func load_stats(unit_type):
	for stat in units.statlines[unit_type].keys():
		_stats[stat] = units.statlines[unit_type][stat]
	_utype = unit_type
	weapon_type = units.get_weapon_type(unit_type)
	if unit_type == UnitTypes.UTYPE.TECHPRIEST:
		empty_lading()
	$SelectionBorder.texture = selection_border_size[units.box_size[unit_type]]
	$Range/CollisionShape2D.shape = CircleShape2D.new()
	$Range/CollisionShape2D.shape.radius = get_range() * 39
	$GatherTimer.wait_time = get_gather_time()
	$ConstructionTimer.wait_time = get_construction_time()
	$AttackTimer.wait_time = get_attack_windup()

	

func set_spriteframes(faction_name, _unit_type):
	var name_string = get_display_name().to_lower().replace(" ", "_")
	var anim_path = "res://Assets/SpriteFrames/Units/" + faction_name + "/" + name_string
	$AnimatedSprite.frames = load(anim_path + "/SpriteFrame.tres")
	#$AnimatedSprite.frames = units.spriteframe_ref[_unit_type]
	$AnimatedSprite.modulate = player_colors[get_player_number()] * 0.5 + Color.white * 0.5


func set_detection_polygon():
	$BBox/Border.polygon = $DetectionArea.polygon

func build_sounds():
	"Assets/Sound/Units/imperium"
	var sound_dir = (
		"res://Assets/Sound/Units/" +
		get_faction().to_lower().replace(" ", "_") + "/" +
		get_display_name().to_lower().replace(" ", "_") + "/"
		)
	for sound_category in [
		["select/", Sounds.SELECT],
		["confirm/", Sounds.CONFIRM],
		["confirm/move_confirm/", Sounds.MOVE_CONFIRM],
		["confirm/attack_confirm/", Sounds.ATTACK_CONFIRM],
		["confirm/gather_confirm/", Sounds.GATHER_CONFIRM],
		["attack_confirm/", Sounds.ATTACK_CONFIRM],
		["attack/", Sounds.ATTACK],
		["death/", Sounds.DEATH]
	]:
		import_sound_subdir(
			sound_dir,
			sound_category[0],
			sound_category[1])


	sound_players[Sounds.EXTRACT] = {
		DepositTypes.DEPOSIT.TREE: [],
		DepositTypes.DEPOSIT.CRYSTAL: [],
		DepositTypes.DEPOSIT.VENT: [],
		DepositTypes.DEPOSIT.ORE: []
	}
	import_sound_subdir(
		sound_dir, "extract/", Sounds.EXTRACT, "ore/", DepositTypes.DEPOSIT.ORE)
	import_sound_subdir(
		sound_dir, "extract/", Sounds.EXTRACT, "tree/", DepositTypes.DEPOSIT.TREE)
	import_sound_subdir(
		sound_dir, "extract/", Sounds.EXTRACT, "crystal/", DepositTypes.DEPOSIT.CRYSTAL)
	import_sound_subdir(
		sound_dir, "extract/", Sounds.EXTRACT, "vent/", DepositTypes.DEPOSIT.VENT)

func import_sound_subdir(sound_dir_str, subdir_str, sound_type_index, subtype_str="", subtype_index=null):
	var directory_string = sound_dir_str + subdir_str + subtype_str
	for sound_file in tools.list_files_in_directory(directory_string):
		if not sound_file.substr(sound_file.length() - 4) == ".ogg": continue
		var new_audioplayer = AudioStreamPlayer2D.new()
		sound_container.add_child(new_audioplayer)
		
		if subtype_str == "":
			new_audioplayer.stream = load(sound_dir_str + subdir_str + sound_file)
			sound_players[sound_type_index].append(new_audioplayer)
		else:
			new_audioplayer.stream = load(sound_dir_str + subdir_str + subtype_str + sound_file)
			sound_players[sound_type_index][subtype_index].append(new_audioplayer)

func get_id(): return _utype

func get_thumbnail(): return units.thumbnail[_utype]
func can_path(): return true
func can_gather(): return false
func empty_lading(): pass
func can_construct(): return true
func get_attack_windup(): return 0.5
func get_attack_speed(): return 1
func get_construction_time(): return 2

func state_changed():
	if state != States.EXTRACT:
		$GatherTimer.stop()
	if state != States.CONSTRUCT:
		$ConstructionTimer.stop()
	if state != States.ATTACK:
		$AttackTimer.stop()

func task_changed():
	if task != Tasks.ATTACK_TARGET:
		$AttackTimer.stop()

func get_task():
	return Tasks.keys()[task]

func set_task_idle():
	task = Tasks.IDLE
	clear_target_unit()
	clear_target_deposit()
	clear_extraction_type()
	clear_target_construction()
	task_changed()
func set_task_move_to_location():
	task = Tasks.MOVE_TO_LOCATION
	task_changed()
func set_task_attack_target():
	task = Tasks.ATTACK_TARGET
	task_changed()
func set_task_die():
	task = Tasks.DIE
	task_changed()
func set_task_rot():
	task = Tasks.ROT
	task_changed()
func set_state_idle(): 
	
	if $AnimationTimer.is_stopped():
		$AnimationTimer.start(tools.rng.randf_range(0.5, 3.0))
	$AnimatedSprite.stop()
	$AnimatedSprite.set_animation(animation_direction + "_idle")
	$AnimatedSprite.set_frame(0)
	additional_idle_functions()
	state = States.IDLE
	state_changed()
func additional_idle_functions(): pass
func get_state():
	return States.keys()[state]
func set_state_move():
	
	if not $AnimationTimer.is_stopped():
		$AnimationTimer.stop()
	$AnimatedSprite.set_animation(animation_direction + "_walk")
	$AnimatedSprite.play()
	additional_move_functions()
	state = States.MOVE
	state_changed()
func additional_move_functions(): pass
func set_state_extract():
	$AnimatedSprite.set_animation(animation_direction + "_idle")
	$AnimatedSprite.play()
	state = States.EXTRACT
	state_changed()
func set_state_construct():
	state = States.CONSTRUCT
	state_changed()

func set_state_attack():
	if $AttackTimer.is_stopped():
		$AttackTimer.start(get_attack_windup())
		$AnimatedSprite.set_animation(animation_direction + "_windup")
		$AnimatedSprite.set_frame(0)
		$AnimatedSprite.play()
	state = States.ATTACK
	state_changed()
func set_state_dying():
	state = States.DYING
	state_changed()
func set_state_dead():
	state = States.DEAD
	state_changed()


func _draw():
	$Target.hide()
	if not selected: return
	if get_tree().root.get_node("Main").draw_targets:
		if final_target != null and final_target != position:
			$Target.show()
			$Target.position = final_target - position
	if not get_tree().root.get_node("Main").draw_paths: return

	var path_pts = []
	path_pts.append(position - position)
	path_pts.append(step_target - position)
	for each_point in path:
		path_pts.append(each_point - position)
	draw_polyline(path_pts, Color.red, 3)

func update_bars():
	if get_maxshields() != 0:
		shield_bar.max_value = get_maxshields()
		shield_bar.value = get_shields()
	$BumpBar.hide()
	$BumpLabel.hide()
	if not bump_timer.is_stopped():
		$BumpBar.show()
		$BumpBar.value = bump_timer.time_left
		$BumpLabel.show()
	health_bar.max_value = get_maxhealth()
	health_bar.value = get_health()


func _process(_delta):
	match task:
		Tasks.DIE:
			pass
		Tasks.ROT:
			pass
		Tasks.IDLE:
			idle_task_logic()
		Tasks.GATHER:
			gather_task_logic()
		Tasks.ATTACK_TARGET:
			attack_task_logic()
		
		Tasks.CONSTRUCT_STRUCTURE:
			construct_task_logic()

		Tasks.MOVE_TO_LOCATION:
			location_move_task_logic()

func _physics_process(delta):
	match state:
		States.IDLE:
			pass
		States.DYING:
			return
		States.ATTACK:
			direction = (target_unit.position - position).normalized()
		States.MOVE:
			if position == final_target or final_target == null:
				if task == Tasks.IDLE:
					set_state_idle()
				elif task == Tasks.MOVE_TO_LOCATION:
					set_state_idle()
				elif task == Tasks.GATHER:
					set_state_extract()
				elif task == Tasks.ATTACK_TARGET:
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
			var k_collision = move_and_collide(movement)

			if not k_collision == null and state == States.MOVE:
				pass
				#bump(k_collision)
			
	# set animation / sprite based on last direction modulo current direction
	# but only if we're still moving.  if we just stopped, don't change the direction
	if direction != last_direction:
		set_animation_facing()
		$AnimatedSprite.set_animation(animation_direction + "_" + get_action_string())

	last_direction = direction

func bump(k_collision):
	var c_fp = k_collision.collider.get_node_or_null("FootPrint")
	var algo_magnitude
	if c_fp: 
		#there might be a bug in here that sends dudes flying if they spawn
		#overlapping
		algo_magnitude = 2 * int(round(
		c_fp.shape.radius * max(c_fp.scale.x, c_fp.scale.y) + 
		$FootPrint.shape.radius * max($FootPrint.scale.x, $FootPrint.scale.y)))
	else:
		algo_magnitude = 32
	var bump_mod = 1.1 + (1 - bump_timer.time_left)
	bump_mod = stepify(bump_mod, 0.01)

	$BumpLabel.text = str(bump_mod)
	$BumpLabel.show()
	if bump_timer.is_stopped() == false:
		algo_magnitude *= bump_mod
		bump_timer.start(bump_timer.time_left + bump_cooldown)


	var reversal_magnitude = algo_magnitude / 6
	var offset_magnitude = algo_magnitude / 2
	var normed_remainder = k_collision.remainder.normalized()
	# The second modified vector is in here so that units will prefer to path
	# 90 degrees to the right to avoid obstacles. this keeps things orderly and
	# emulates real life
	var offset_vector = tools.r_choice([
		Vector2(-normed_remainder.y, normed_remainder.x) * offset_magnitude,
		Vector2(normed_remainder.y, -normed_remainder.x) * offset_magnitude,
		Vector2(normed_remainder.y, -normed_remainder.x) * offset_magnitude])
	var offset_location = position + normed_remainder * -reversal_magnitude + offset_vector
	position = position + normed_remainder * -1
	if path.empty():
		path.insert(0, step_target)
	step_target = offset_location
	bump_timer.start(bump_cooldown)

func location_move_task_logic():
	match state:
		States.IDLE:
			if not waypoints.empty():
				move_to(get_next_waypoint())
			else:
				set_task_idle()
		States.MOVE:
			return

func gather_task_logic():
	pass

func idle_task_logic(): pass

func attack_task_logic():
	# Check if our target still exists
	if target_unit == null:
		set_task_idle()
		set_state_idle()
		return
	# Check if our target is dead/dying
	if target_unit.task == Tasks.DIE or target_unit.task == Tasks.ROT:
		set_task_idle()
		set_state_idle()
		return
	if target_unit.state == States.DYING or target_unit.state == States.DEAD:
		set_task_idle()
		set_state_idle()
		return

	# Check if our target moved and repath if so
	if target_unit.position != final_target:
		path_to(target_unit.get_center())

	# Check if we are in range, and if so, switch state to attacking
	if check_contact(target_unit, get_range() * 39):
		match state:
			States.ATTACK:
				return
		set_state_attack()
		
	else:
		set_state_move()

func construct_task_logic():
	# are we at the construction target?
	if not check_contact(target_construction): return
	# have we started constructing already?
	if state == States.CONSTRUCT: return
	# if not, start
	start_construct()

func start_gather():pass
func start_construct(): pass
func zero_target():
	final_target = position
	path = []
	step_target = position

func set_target_unit(new_target_unit):
	target_unit = new_target_unit
	target_unit.set_targeted(self)
	direction = (target_unit.position - position).normalized()
	set_task_attack_target()

func clear_target_unit():
	if not target_unit: return
	target_unit.set_untargeted(self)
	target_unit = null
	$AttackTimer.stop()

func set_target_construction(tile):
	target_construction = map_grid.get_structure_at(tile)
	path_to(target_construction.get_center())

func clear_target_construction():
	if not target_construction: return
	target_construction = null

func path_to(target_world_pos):
	var nav_path = nav2d.get_simple_path(position, target_world_pos, true)
	if nav_path.size() < 1:
		return
	final_target = nav_path[nav_path.size()-1]
	set_path(nav_path)
	
func player_right_clicked(player_id, target_world_pos, shift):
	if player_id != get_player_number():
		return
	move_to(target_world_pos, shift)

func move_to(target_world_pos, shift=false):
	path_to(target_world_pos)
	set_task_move_to_location()
	set_state_move()
	if !shift:
		clear_waypoints()
		clear_target_unit()
		clear_target_deposit()

func add_waypoint(waypoint):
	if task == Tasks.IDLE:
		move_to(waypoint)
		return

	waypoints.append(waypoint)

func set_animation_facing():
	if direction != Vector2.ZERO:
		animation_direction = get_sprite_direction(direction)
	else: 
		animation_direction = get_sprite_direction(last_direction)

func get_action_string():
	match state:
		States.IDLE:
			return "idle"
		States.MOVE:
			return "walk"
		States.EXTRACT:
			return "extract"
		States.ATTACK:
			return "attack"
		States.DYING:
			return "dying"
	return "idle"
			

func get_sprite_direction(dir: Vector2):
	var norm_direction = dir.normalized()
	if norm_direction.y >= 0.6:
		if norm_direction.x >= 0.4:
			return "down_right"
		elif norm_direction.x <= -0.4:
			return "down_left"
		else:
			return "down"
	elif norm_direction.y <= -0.6:
		if norm_direction.x >= 0.4:
			return "up_right"
		elif norm_direction.x <= -0.4:
			return "up_left"
		else:
			return "up"
	elif norm_direction.x <= -0.6:
		if norm_direction.y >= 0.4:
			return "down_left"
		elif norm_direction.y <= -0.4:
			return "up_left"
		else:
			return "left"
	elif norm_direction.x >= 0.6:
		if norm_direction.y >= 0.4:
			return "down_right"
		elif norm_direction.y <= -0.4:
			return "up_right"
		else:
			return "right"
	else:
		return "down_right"

func take_damage(damage_type, damage_amt, attacker=null):
	if task == Tasks.DIE: return
	if state == States.DYING: return

	set_aggressive(attacker)

	var shield_carryover = damage_amt
	if not get_shields() == 0:
		shield_carryover = max(0, get_shields() - damage_amt)
		emit_signal("shield_damage")
	var armor_carryover = shield_carryover
	if not get_armor() == 0:
		armor_carryover = max(1, shield_carryover - get_armor())
	armor_carryover = damage_amt
	set_health(max(0, get_health() - armor_carryover))
	if get_health() == 0:
		kill()

	emit_signal("update", self)

func set_aggressive(new_target):
	if task == Tasks.ATTACK_TARGET: return
	if not new_target: set_task_attack_target()
	else: set_target_unit(new_target)

func kill():
	# emit_signal("kill", self, targeted_by)
	set_task_die()
	set_state_dying()
	$AnimatedSprite.set_animation(animation_direction + "_dying")
	$AnimatedSprite.set_frame(0)
	$AnimatedSprite.play()

func _on_GatherTimer_timeout():
	pass

func _on_ConstructionTimer_timeout():
	pass

func get_weapon_offset():
	return (
		Vector2(0, -barrel_height[_utype]) + 
		Vector2(0, -barrel_length[_utype]).rotated(position.angle_to(-last_direction)))

func get_weapon_data():
	if get_id() == Types.UTYPE.PREDATOR or get_id() == Types.UTYPE.LASCANNON:
		return lasbeam_data
	elif get_id() == Types.UTYPE.MARINE:
		return boltershell_data
	else:
		return lasbolt_data

func _on_AttackTimer_timeout():
	assert (state == States.ATTACK)
	$AttackTimer.stop()
	$AttackTimer.start(get_attack_speed())
	$AnimatedSprite.set_animation(animation_direction + "_attack")
	$AnimatedSprite.set_frame(0)
	$AnimatedSprite.play()

	if weapon_type == Types.WEAPON.PROJECTILE:
		proj.add_projectile(
			position + get_weapon_offset(),
			get_player_number(),
			target_unit,
			get_weapon_data(),
			self)
		play_attack_sound()
		return
	elif weapon_type == Types.WEAPON.HITSCAN:
		pass
	elif weapon_type == Types.WEAPON.BEAM:
		proj.add_beam(
			position + get_weapon_offset(),
			get_player_number(),
			target_unit,
			get_weapon_data(),
			self)
		play_attack_sound()
			
		return
	elif weapon_type == Types.WEAPON.MELEE:
		pass

func _on_KillTimer_timeout():
	queue_free()

func _on_AnimationTimer_timeout():
	$AnimatedSprite.set_frame(0)
	$AnimatedSprite.play()

func _on_AnimatedSprite_animation_finished():
	var animation_direction
	if direction != Vector2.ZERO:
		animation_direction = get_sprite_direction(direction)
	else: 
		animation_direction = get_sprite_direction(last_direction)

	match state:
		States.IDLE:
			$AnimationTimer.stop()
			$AnimationTimer.start(tools.rng.randf_range(1.5, 5.0))
		States.IDLE:
			$AnimatedSprite.set_animation(animation_direction + "idle")
			$AnimatedSprite.set_frame(0)
			$AnimatedSprite.play()
		States.ATTACK:
			$AnimatedSprite.set_animation(animation_direction + "_attack_idle")
			$AnimatedSprite.set_frame(0)
			$AnimatedSprite.play()

		States.DYING:
			$KillTimer.start()
			$AnimatedSprite.stop()
			$AnimatedSprite.set_animation(animation_direction + "_rot")
			$AnimatedSprite.set_frame(0)
			set_task_rot()
		
