extends KinematicBody2D

# Signal Declarations
signal left_clicked
signal right_clicked
signal unit_spawned
signal spawn_sound
signal set_rally_point

# Module References
var tools
var dis
var ui_sounds
var units
var st
onready var unit_scn = preload("res://Scenes/Unit.tscn")
onready var center_widget = get_tree().root.get_node("Main/UILayer/CenterWidget")

# mutable internal properties
var _player_owner
var selected = false
var target_unit = null
var state = "Idle"
var rally_point = null
var pos : Vector2
var constructed = false


# variable statline properties, filled out for different units programmatically
var build_options = []
var tech_options = []
var width = 1
var height = 1
var stype
var _stats = {}
var build_queue = []
var spawn_radius = 250

func setup(player_owner, structure_type, tile_coordinates, location, structure_built):
	set_module_refs()
	connect_signals()
	load_stats(structure_type)
	_player_owner = player_owner
	pos = tile_coordinates
	position = location
	set_construction(structure_built)

func _process(_delta):
	update_display_bars()

func set_module_refs():
	tools = get_tree().root.get_node("Main/Tools")
	dis = get_tree().root.get_node("Main/Dispatcher")
	units = get_tree().root.get_node("Main/GameObjects/Units")
	ui_sounds = get_tree().root.get_node("Main/Sounds/UI")
	st = get_tree().root.get_node("Main/GameObjects/Structures")

func connect_signals():
	self.connect("left_clicked", dis, "_on_Unit_left_clicked")
	self.connect("right_clicked", dis, "_on_Unit_right_clicked")
	self.connect("unit_spawned", dis, "_on_Build_Structure_unit_spawned")
	self.connect("spawn_sound", ui_sounds, "_on_spawn_sound")
	self.connect("set_rally_point", dis, "_on_Build_Structure_set_rally_point")

func load_stats(structure_type):
	for _stat in st.statlines[structure_type].keys():
		_stats[_stat] = st.statlines[structure_type][_stat]
	_stats[Stats.STAT.HEALTH] = st.statlines[structure_type][Stats.STAT.MAXHEALTH]
	_stats[Stats.STAT.SHIELDS] = st.statlines[structure_type][Stats.STAT.MAXSHIELDS]
	stype = structure_type
	width = st.get_width(structure_type)
	height = st.get_height(structure_type)
	set_areas(Vector2(width, height))

	if structure_type in st.build_options.keys():
		build_options = st.build_options[structure_type]
	if structure_type in st.tech_options.keys():
		tech_options = st.tech_options[structure_type]

	set_icon(structure_type)
	update_display_bars()

func increment_construction(quantity):
	$BuildBar.value += quantity
	construction_check()

func construction_check():
	if $BuildBar.value >= 100:
		set_construction(true)

func set_construction(build_complete):
	constructed = build_complete
	$BuildBar.value = 0
	if build_complete:
		$Sprite.show()
		$Foundation.hide()
		return

	$Sprite.hide()

func get_thumbnail():
	return st.thumbnail[stype]

func set_areas(structure_size):
	set_selection_box(Vector2(width, height))
	set_detection_polygon(Vector2(width, height))

	var collision_polygons = {
		Vector2(1, 1): $CollisionPolygon1x,
		Vector2(2, 2): $CollisionPolygon2x,
		Vector2(3, 3): $CollisionPolygon3x,
		Vector2(4, 4): $CollisionPolygon4x
	}
	collision_polygons[structure_size].disabled = false
	$NavPolygon2D.polygon = collision_polygons[structure_size].get_polygon()
	$ContactZone.polygon = collision_polygons[structure_size].get_polygon()
	$NavPolygon2D.scale = Vector2(1.1, 1.1)
	$NavPolygon2D.position -= (get_center() - position) * 0.1
	$ContactZone.scale = Vector2(1.1, 1.1)
	$ContactZone.position -= (get_center() - position) * 0.1
	$ContactZone.disabled = false
	
	set_spawn_area(collision_polygons[structure_size].get_polygon())

func set_spawn_area(collision_polygon):
	var new_polygon = PoolVector2Array()
	for vertex in collision_polygon:
		new_polygon.append(
			vertex * Vector2(1.25, 1.25) - (get_center() - position) * 0.25)
	# new_polygon *= Vector2(1.25, 1.25)
	# new_polygon -= (get_center() - position) * 0.25
	for each_vertex in new_polygon:
		$SpawnArea.curve.add_point(each_vertex)

func set_selection_box(structure_size):
	var box_textures = {
		Vector2(1, 1): preload("res://Assets/Art/UI/selection_box_1x1.png"),
		Vector2(2, 2): preload("res://Assets/Art/UI/selection_box_2x2.png"),
		Vector2(3, 3): preload("res://Assets/Art/UI/selection_box_3x3.png"),
		Vector2(4, 4): preload("res://Assets/Art/UI/selection_box_4x4.png")
	}
	$SelectionBox.texture = box_textures[structure_size]

func set_detection_polygon(structure_size):
	var detection_polygons = {
		Vector2(1, 1): $BBox/X1,
		Vector2(2, 2): $BBox/X2,
		Vector2(3, 3): $BBox/X3,
		Vector2(4, 4): $BBox/X4
	}
	detection_polygons[structure_size].disabled = false

func update_display_bars():
	$BuildBar.hide()
	$ShieldBar.hide()
	if not build_queue.empty():
		$BuildBar.show()
		$BuildBar.value = 100 - ($BuildTimer.time_left / $BuildTimer.wait_time) * 100
	if not _stats[Stats.STAT.MAXSHIELDS] == 0:
		$ShieldBar.show()
	$ShieldBar.value = _stats[Stats.STAT.SHIELDS]
	$HealthBar.max_value = _stats[Stats.STAT.MAXHEALTH]
	$HealthBar.value = _stats[Stats.STAT.HEALTH]
	if not constructed:
		$BuildBar.show()

func get_world_pos(): return position
func get_tile_coords(): return pos
func get_player_number(): return _player_owner
func get_id(): return _stats[Stats.STAT.STRUCTURE_ID]
func get_display_name(): return _stats[Stats.STAT.DISPLAY_NAME]
func get_speed(): return _stats[Stats.STAT.SPEED]
func get_armor(): return _stats[Stats.STAT.ARMOR]
func get_health(): return _stats[Stats.STAT.HEALTH]
func get_maxhealth(): return _stats[Stats.STAT.MAXHEALTH]
func get_shields(): return _stats[Stats.STAT.SHIELDS]
func get_maxshields(): return _stats[Stats.STAT.MAXSHIELDS]
func get_attack(): return _stats[Stats.STAT.ATTACK]
func get_range(): return _stats[Stats.STAT.RANGE]
func get_build_time(): return _stats[Stats.STAT.BUILD_TIME]
func get_gather_time(): return _stats[Stats.STAT.GATHER_TIME]
func get_sight(): return _stats[Stats.STAT.SIGHT]
func get_carry_cap(): return _stats[Stats.STAT.CARRY_CAP]
func is_boxable(): return true
func get_cost(): return _stats[Stats.STAT.COST]
func confirm(): pass

func get_footprint_offset():
	return Vector2(0, -26 * sqrt(width * height))

func get_center():
	return Vector2(
		position.x,
		position.y + 26 * sqrt(width * height)
			)

func set_icon(structure_type):
	$Sprite.texture = st.icons[structure_type]
	$Foundation.texture = st.foundation_sprites[structure_type]


func _draw():
	if not selected: return

func play_move_confirm():
	pass

func player_right_click(player_id, target_world_position, shift):
	if player_id != get_player_number():
		return
	set_rally_point(target_world_position, shift)

func set_rally_point(target_world_position, shift=false):
	rally_point = target_world_position
	emit_signal("set_rally_point")

func clear_rally_point():
	rally_point = null

func set_target_unit(new_target_unit):
	target_unit = new_target_unit

func clear_target_unit():
	return

func spawn_unit(unit_type):
	if rally_point != null:
		units.add_unit(
			get_player_number(),
			unit_type,
			position + get_spawn_location(rally_point),
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

func select():
	selected = true
	$SelectionBox.show()
	$HealthBar.show()

func play_greeting():
	get_tree().root.get_node("Main/Sounds/UI/Laser1").play()

func deselect():
	selected = false
	$SelectionBox.hide()
	$HealthBar.hide()

func _on_BBox_mouse_entered():
	$SelectionBox.show()
	$HealthBar.show()

func _on_BBox_mouse_exited():
	if selected: return
	$SelectionBox.hide()
	$HealthBar.hide()

func _on_BBox_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("left_click"):
		emit_signal("left_clicked", self)
	elif event.is_action_pressed("right_click"):
		emit_signal("right_clicked", self)

func _on_BuildTimer_timeout():
	spawn_unit(build_queue.pop_front())
	start_next_in_queue()

func start_next_in_queue():
	if build_queue.empty():
		$BuildTimer.stop()
		$BuildBar.hide()
		return
	#$BuildTimer.wait_time = units.get_build_time(build_queue[0])
	$BuildTimer.wait_time = 0.1
	$BuildTimer.start()

func get_footprint():
	return(st.get_footprint_tiles(stype, pos))
	
