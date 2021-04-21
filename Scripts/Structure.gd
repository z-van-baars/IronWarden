extends KinematicBody2D

# Signal Declarations
signal left_clicked
signal right_clicked
signal production_building_selected
signal unit_spawned
signal set_rally_point

enum Stats {
	STRUCTURE_ID,
	DISPLAY_NAME,
	ARMOR,
	HEALTH,
	MAXHEALTH,
	SHIELDS,
	MAXSHIELDS,
	ATTACK,
	RANGE,
	COST
}

# Module References
var tools
var dis
var units
var st
onready var unit_scn = preload("res://Scenes/Unit.tscn")
onready var center_widget = get_tree().root.get_node("Main/UILayer/CenterWidget")

# mutable internal properties
var can_path = false
var can_gather = false
var selected = false
var target_entity = null
var state = "Idle"
var rally_point = null
var pos : Vector2


# variable statline properties, filled out for different units programmatically
var build_options = []
var tech_options = []
var width = 1
var height = 1
var stype
var _stats
var build_queue = []
var spawn_radius = 250

func setup(structure_type, tile_coordinates, location):
	set_module_refs()
	connect_signals()
	load_stats(structure_type)
	pos = tile_coordinates
	position = location

func _process(delta):
	update_display_bars()

func set_module_refs():
	tools = get_tree().root.get_node("Main/Tools")
	units = get_tree().root.get_node("Main/GameObjects/Units")
	dis = get_tree().root.get_node("Main/Dispatcher")
	st = get_tree().root.get_node("Main/GameObjects/Structures")

func connect_signals():
	self.connect("left_clicked", dis, "_on_Unit_left_clicked")
	self.connect("unit_spawned", dis, "_on_Build_Structure_unit_spawned")
	self.connect("set_rally_point", dis, "_on_Build_Structure_set_rally_point")

func load_stats(structure_type):
	_stats = st.statlines[structure_type]
	_stats[Stats.HEALTH] = st.statlines[structure_type][Stats.MAXHEALTH]
	_stats[Stats.SHIELDS] = st.statlines[structure_type][Stats.MAXSHIELDS]
	stype = structure_type
	width = st.get_width(structure_type)
	height = st.get_height(structure_type)
	set_collision(Vector2(width, height))
	set_selection_box(Vector2(width, height))
	set_detection_polygon(Vector2(width, height))
	if structure_type in st.build_options.keys():
		build_options = st.build_options[structure_type]
	if structure_type in st.tech_options.keys():
		tech_options = st.tech_options[structure_type]

	set_icon(structure_type)
	update_display_bars()

func set_collision(structure_size):
	var collision_polygons = {
		Vector2(1, 1): $CollisionPolygon1x,
		Vector2(2, 2): $CollisionPolygon2x,
		Vector2(3, 3): $CollisionPolygon3x,
		Vector2(4, 4): $CollisionPolygon4x
	}
	collision_polygons[structure_size].disabled = false
	$NavPolygon2D.polygon = collision_polygons[structure_size].get_polygon()
	$NavPolygon2D.scale = Vector2(1.1, 1.1)

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
	if not _stats[Stats.MAXSHIELDS] == 0:
		$ShieldBar.show()
	$ShieldBar.value = _stats[Stats.SHIELDS]
	$HealthBar.max_value = _stats[Stats.MAXHEALTH]
	$HealthBar.value = _stats[Stats.HEALTH]

func get_unit_id(): return _stats[Stats.UNIT_ID]

func get_display_name(): return _stats[Stats.DISPLAY_NAME]

func get_speed(): return _stats[Stats.SPEED]

func get_armor(): return _stats[Stats.ARMOR]

func get_health(): return _stats[Stats.HEALTH]

func get_maxhealth(): return _stats[Stats.MAXHEALTH]

func get_shields(): return _stats[Stats.SHIELDS]

func get_maxshields(): return _stats[Stats.MAXSHIELDS]

func get_attack(): return _stats[Stats.ATTACK]

func get_range(): return _stats[Stats.RANGE]

func get_build_time(): return _stats[Stats.BUILD_TIME]

func get_gather_time(): return _stats[Stats.GATHER_TIME]

func get_carry_cap(): return _stats[Stats.CARRY_CAP]

func is_boxable(): return true

func get_cost(): return _stats[Stats.COST]

func confirm(): pass

func get_center():
	return Vector2(
		position.x,
		position.y + 26 * sqrt(width * height)
			)

func set_icon(structure_type):
	$Sprite.texture = st.icons[structure_type]


func _draw():
	if not selected: return

func set_rally_point(location):
	rally_point = location
	emit_signal("set_rally_point")

func clear_rally_point():
	rally_point = null

func spawn_unit(unit_type):
	if rally_point != null:
		units.add_unit(unit_type, position + tools.circ_random(get_center(), spawn_radius), rally_point)
	else:
		units.add_unit(unit_type, position + tools.circ_random(get_center(), spawn_radius))
	emit_signal("unit_spawned", unit_type)

func add_to_queue(unit_type):
	if build_queue == []:
		$BuildTimer.wait_time = units.get_build_time(unit_type)
		$BuildTimer.start()
	build_queue.append(unit_type)

func select():
	selected = true
	$SelectionBox.show()
	$HealthBar.show()
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

func _on_BBox_input_event(viewport, event, shape_idx):
	if event.is_action_released("left_click"):
		emit_signal("left_clicked", self)
	elif event.is_action_pressed("right_click"):
		emit_signal("right_clicked", self)

func _on_BuildTimer_timeout():
	spawn_unit(build_queue.pop_front())
	if build_queue.empty():
		$BuildTimer.stop()
		$BuildBar.hide()
		return
	$BuildTimer.wait_time = units.get_build_time(build_queue[0])
	$BuildTimer.start()

func get_footprint():
	return(st.get_footprint_tiles(stype, pos))


func get_collision_shape():

	return
	
