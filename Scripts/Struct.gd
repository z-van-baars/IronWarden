extends "res://Scripts/GameObject.gd"

# Unique Signal Declarations
signal unit_spawned
signal spawn_sound
signal set_rally_point
signal finished

enum States {
	IDLE,
	BUILDING,
	DYING,
	DEAD
}
# mutable internal properties
var rally_point = null
var _constructed = false


# variable statline properties, filled out for different units programmatically
var width = 1
var height = 1
var _constructors = []
var build_queue = []
var _construction_progress = 0

func sub_connect():
	self.connect("unit_spawned", dis, "_on_Build_Structure_unit_spawned")
	self.connect("set_rally_point", dis, "_on_Build_Structure_set_rally_point")

func setup(structure_type, location, player_owner):
	set_module_refs()
	connect_signals()
	load_stats(structure_type)
	_player_owner = player_owner
	position = location
	pos = map_grid.get_tile(position)
	set_faction(st.get_faction(structure_type))
	set_spriteframes(st.get_faction(structure_type), structure_type)
	build_sounds()
	zero_target()

func load_stats(structure_type):
	for _stat in st.statlines[structure_type].keys():
		_stats[_stat] = st.statlines[structure_type][_stat]
	_stats[Stats.STAT.HEALTH] = st.statlines[structure_type][Stats.STAT.MAXHEALTH]
	_stats[Stats.STAT.SHIELDS] = st.statlines[structure_type][Stats.STAT.MAXSHIELDS]
	_stype = structure_type
	width = st.get_width(structure_type)
	height = st.get_height(structure_type)
	set_selection_border(Vector2(width, height))
	set_footprint_polygon(Vector2(width, height))
	set_detection_polygon(Vector2(width, height))
	set_spawn_area(Vector2(width, height))

	if structure_type in st.build_options.keys():
		build_options = st.build_options[structure_type]
	if structure_type in st.tech_options.keys():
		tech_options = st.tech_options[structure_type]
	update_bars()

func set_spriteframes(faction_name, structure_type):
	#var name_string = get_display_name().to_lower().replace(" ", "_")
	#var anim_path = "res://Assets/SpriteFrames/Structures/" + faction_name + "/" + name_string
	#$AnimatedSprite.frames = load(anim_path + "/SpriteFrame.tres")
	#$AnimatedSprite.frames = st.spriteframe_ref[structure_type]
	$Sprite.texture = st.icons[structure_type]
	$Sprite.modulate = player_colors[get_player_number()] * 0.5 + Color.white * 0.5

	
func build_sounds():
	var sound_dir = (
		"res://Assets/Sound/Structures/" +
		get_display_name().to_lower().replace(" ", "_") + "/"
		)
	for sound_category in [
		["select/", Sounds.SELECT],
		["set_rally_point/", Sounds.SET_RALLY_POINT],
		["unit_built/", Sounds.UNIT_BUILT],
		["death/", Sounds.DEATH]
	]:
		import_sound_subdir(
			sound_dir,
			sound_category[0],
			sound_category[1])

func connect_construction_signal(constructor):
	_constructors.append(constructor)
	self.connect("finished", constructor, "_on_TargetConstruction_finished")

func disconnect_construction_signal(constructor):
	_constructors.erase(constructor)
	self.disconnect("finished", constructor, "_on_TargetConstruction_finished")

func _process(_delta):
	update_bars()

func increment_construction(quantity=1):
	_construction_progress += quantity
	construction_check()
	var construction_opacity = 0.5
	# construction_opacity += (_construction_progress / 100.0) / 2.0
	# $Sprite.modulate.a = construction_opacity
	if _constructed:
		$Sprite.texture = st.icons[_stype]
	else:
		$Sprite.texture = load("res://Assets/Art/Structures/foundations/%0x%1.png".format(
			[str(width), str(height)], "%_"))
	update_bars()

func construction_check():
	if _construction_progress >= 100:
		set_constructed(true)

func set_constructed(construction_complete):
	_constructed = construction_complete
	if construction_complete:
		emit_signal("finished")
		return
	_construction_progress = 0
	update_bars()
	$Sprite.texture = load("res://Assets/Art/Structures/foundations/%0x%1.png".format(
		[str(width), str(height)], "%_"))

func get_constructed():
	return _constructed

func get_thumbnail():
	return st.thumbnail[_stype]

func get_stype(): return _stype

func set_spawn_area(structure_size):
	for vertex in FootprintSizes[structure_size]:
		$SpawnArea.curve.add_point(
			vertex * Vector2(1.25, 1.25) - (get_center() - position) * 0.25)

func set_selection_border(structure_size):
	$SelectionBorder.texture = load("res://Assets/Art/UI/selection_border_%0x%1.png".format(
		[str(structure_size.x), str(structure_size.y)], "%_"))
	$SelectionBorder.position = Vector2(0, -42)

func set_detection_polygon(structure_size):
	$BBox/Border.polygon = PoolVector2Array(DetectionPolygons[structure_size])

func set_footprint_polygon(structure_size):
	$Footprint.polygon = PoolVector2Array(FootprintSizes[structure_size])

func update_bars():
	$ProgressBar.hide()
	$ShieldBar.hide()
	if not build_queue.empty():
		$ProgressBar.show()
		$ProgressBar.value = 100 - ($BuildTimer.time_left / $BuildTimer.wait_time) * 100
	if not _stats[Stats.STAT.MAXSHIELDS] == 0:
		$ShieldBar.show()
	$ShieldBar.value = _stats[Stats.STAT.SHIELDS]
	$HealthBar.max_value = _stats[Stats.STAT.MAXHEALTH]
	$HealthBar.value = _stats[Stats.STAT.HEALTH]
	if not _constructed:
		$ProgressBar.show()
		$ProgressBar.value = _construction_progress

func get_id(): return _stats[Stats.STAT.STRUCTURE_ID]

func get_footprint_offset():
	return Vector2(0, -26 * sqrt(width * height))

func get_footprint_tiles():
	return(st.get_footprint_tiles(_stype, pos))

func get_center():
	return Vector2(
		position.x,
		position.y + 26 * sqrt(width * height) - 26
			)

func set_target_unit(new_target_unit):
	target_unit = new_target_unit
	target_unit.set_targeted(self)
	direction = (target_unit.position - position).normalized()

func take_damage(damage_type, damage_amt, attacker=null):
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
	set_target_unit(new_target)

func play_move_confirm():
	pass

func player_right_clicked(player_id, target_world_position, shift):
	if player_id != get_player_number():
		return
	set_rally_point(target_world_position, shift)

func set_rally_point(target_world_position, shift=false):
	rally_point = target_world_position
	play_sound(Sounds.SET_RALLY_POINT)
	emit_signal("set_rally_point")

func clear_rally_point():
	rally_point = null

func spawn_unit(unit_type):
	if rally_point != null:
		units.add_unit(
			unit_type,
			position + get_spawn_location(rally_point),
			get_player_number(),
			rally_point
			)
	else:
		units.add_unit(
			unit_type,
			position + get_spawn_location(),
			get_player_number()
			)
	emit_signal("unit_spawned", unit_type)
	emit_signal("spawn_sound")

func get_spawn_location(set_rally_point=null):
	# this needs a check for blocked spawn locations
	if not rally_point: return tools.r_choice($SpawnArea.curve.get_baked_points())
	return $SpawnArea.curve.get_closest_point(set_rally_point - position)

func add_to_queue(unit_type):
	if build_queue.empty():
		# $BuildTimer.wait_time = units.get_build_time(unit_type)
		$BuildTimer.wait_time = 0.1
		$BuildTimer.start()
	build_queue.append(unit_type)

func _on_BuildTimer_timeout():
	spawn_unit(build_queue.pop_front())
	start_next_in_queue()

func start_next_in_queue():
	if build_queue.empty():
		$BuildTimer.stop()
		$ProgressBar.hide()
		return
	#$BuildTimer.wait_time = units.get_build_time(build_queue[0])
	$BuildTimer.wait_time = 0.1
	$BuildTimer.start()

	
