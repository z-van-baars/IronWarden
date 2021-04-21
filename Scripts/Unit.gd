extends KinematicBody2D

# Signal Declarations
signal left_clicked
signal right_clicked
signal confirm
signal update

# Enums
enum Tasks {
	TASK_IDLE,
	TASK_GATHER,
	TASK_ATTACK_TARGET,
	TASK_BUILD_STRUCTURE
}

enum States {
	STATE_MOVE,
	STATE_ATTACK,
	STATE_EXTRACT,
	STATE_IDLE
}

enum Stats {
	UNIT_ID,
	DISPLAY_NAME,
	SPEED,
	ARMOR,
	HEALTH,
	MAXHEALTH,
	SHIELDS,
	MAXSHIELDS,
	ATTACK,
	RANGE,
	BUILD_TIME,
	GATHER_TIME,
	CARRY_CAP,
	COST
}


# Module References
var tools
var nav
var nav2d
var player
var dis
var structures
var units
var res

# mutable internal properties
var selected = false
var last_direction = Vector2(0, 1)
var direction : Vector2
var step_target : Vector2
var final_target : Vector2
var path = []

var target_unit = null
var state
var task


# variable statline properties, filled out for different units programmatically
var can_path = true
var can_gather = false
var can_build = false
var build_options = []
var tech_options = []

var utype
var _stats

onready var bounding_boxes = {
	"human": $BBoxHuman,
	"vehicle": $BBoxVehicle}

onready var selection_border_size = {
	"human": preload("res://Assets/Art/UI/selection_border_small.png"),
	"vehicle": preload("res://Assets/Art/UI/selection_border_large.png")}

onready var directional_sprites = {
	"up": $UpSprite,
	"upright": $UpRightSprite,
	"right": $RightSprite,
	"downright": $DownRightSprite,
	"down": $DownSprite,
	"downleft": $DownLeftSprite,
	"left": $LeftSprite,
	"upleft": $UpLeftSprite}




func _ready():
	set_module_refs()

func set_module_refs():
	tools = get_tree().root.get_node("Main/Tools")
	nav = get_tree().root.get_node("Main/Nav2D/NavMap")
	nav2d = get_tree().root.get_node("Main/Nav2D")
	player = get_tree().root.get_node("Main/Player")
	dis = get_tree().root.get_node("Main/Dispatcher")
	structures = get_tree().root.get_node("Main/GameObjects/Structures")
	units = get_tree().root.get_node("Main/GameObjects/Units")
	res = get_tree().root.get_node("Main/GameObjects/Resources")

func connect_signals():
	self.connect("left_clicked", dis, "_on_Unit_left_clicked")
	self.connect("confirm", dis, "_on_Unit_confirm")
	self.connect("update", dis, "_on_Unit_update")

func setup(unit_type, location):
	set_module_refs()
	connect_signals()
	load_stats(unit_type)
	position = location
	zero_target()
	set_task_idle()

func confirm(): emit_signal("confirm", self)

func empty_lading(): pass

func set_task_idle(): task = Tasks.TASK_IDLE

func set_state_idle(): state = States.STATE_IDLE

func set_state_move(): state = States.STATE_MOVE

func set_state_extract(): state = States.STATE_EXTRACT

func set_state_attack(): state = States.STATE_ATTACK

func load_stats(unit_type):
	_stats = units.statlines[unit_type]
	_stats[Stats.HEALTH] = units.statlines[unit_type][Stats.MAXHEALTH]
	_stats[Stats.SHIELDS] = units.statlines[unit_type][Stats.MAXSHIELDS]
	
	utype = unit_type
	if unit_type == units.UnitTypes.UNIT_TECHPRIEST:
		can_gather = true
		can_build = true
		empty_lading()
	set_icons(unit_type)
	bounding_boxes[units.box_size[unit_type]].input_pickable = true
	$SelectionBox.texture = selection_border_size[units.box_size[unit_type]]

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

func get_cost(): return _stats[Stats.COST]

func is_boxable(): return true

func get_center(): return Vector2(position.x, position.y)


func set_icons(unit_type):
	var _icon_list = units.icons[unit_type]
	$UpSprite.texture = _icon_list[0]
	$UpRightSprite.texture = _icon_list[1]
	$RightSprite.texture = _icon_list[2]
	$DownRightSprite.texture = _icon_list[3]
	$DownSprite.texture = _icon_list[4]
	$DownLeftSprite.texture = _icon_list[5]
	$LeftSprite.texture = _icon_list[6]
	$UpLeftSprite.texture = _icon_list[7]

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

func update_bars():
	if get_maxshields() != 0:
		$ShieldBar.max_value = get_maxshields()
		$ShieldBar.value = get_shields()
	$HealthBar.max_value = get_maxhealth()
	$HealthBar.value = get_health()


func _process(delta):
	update_bars()
	if target_unit != null:
		# Check if our target moved and repath if so
		if target_unit.position != final_target:
			path_to(target_unit.get_center())
	update()

func _physics_process(delta):
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
	var collisions = move_and_collide(movement)
	if not collisions == null:
		pass
		# print(collisions)
	# set animation / sprite based on last direction modulo current direction
	if direction != last_direction:
		get_facing()
	
	last_direction = direction

func zero_target():
	final_target = position
	path = []
	step_target = position

func check_contact(queried_object):
	var space = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	var contact_zone = CircleShape2D.new()
	contact_zone.radius = 26
	query.set_shape(contact_zone)
	query.transform = Transform2D(0, get_center())
	var collisions = space.intersect_shape(query)
	for entry in collisions:
		if entry.collider == queried_object:
			return true
	return false

func get_step_target():
	var new_step_target = nav.map_to_world(path[0])
	path.remove(0)
	step_target = Vector2(new_step_target.x, new_step_target.y)
	direction = (step_target - position).normalized()

func path_to(target_world_pos):
	var nav_path = nav2d.get_simple_path(position, target_world_pos, true)
	if nav_path.size() < 1:
		return
	final_target = nav_path[nav_path.size()-1]
	set_path(nav_path)


func set_path(new_path):
	path = new_path
	step_target = path[0]
	path.remove(0)

func get_facing():
	var sprite_direction = get_sprite_direction(direction)
	for sprite in directional_sprites.values():
		sprite.hide()
	directional_sprites[sprite_direction].show()

func get_sprite_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		if norm_direction.x >= 0.3:
			return "downright"
		elif norm_direction.x <= -0.3:
			return "downleft"
		else:
			return "down"
	elif norm_direction.y <= -0.707:
		if norm_direction.x >= 0.3:
			return "upright"
		elif norm_direction.x <= -0.3:
			return "upleft"
		else:
			return "up"
	elif norm_direction.x <= -0.707:
		if norm_direction.y >= 0.3:
			return "downleft"
		elif norm_direction.y <= -0.3:
			return "upleft"
		else:
			return "left"
	elif norm_direction.x >= 0.707:
		if norm_direction.y >= 0.3:
			return "downright"
		elif norm_direction.y <= -0.3:
			return "upright"
		else:
			return "right"
	return "downright"


func select():
	selected = true
	$SelectionBox.show()
	$HealthBar.show()

func deselect():
	selected = false
	$SelectionBox.hide()
	$HealthBar.hide()

func _health_changed():
	$HealthBar.value = get_health()

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

