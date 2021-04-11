extends KinematicBody2D

# Signal Declarations
# signal left_click
signal right_click

# Module References
var tools
var nav
var nav2d
var player
var dispatcher
var units

# mutable internal properties
var can_path = true
var selected = false
var last_direction = Vector2(0, 1)
var direction : Vector2
var step_target : Vector2
var final_target : Vector2
var path = []
var target_entity = null
var state = "Idle"

# variable statline properties, filled out for different units programmatically
var display_name
var speed
var health
var attack
var attack_range

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
	dispatcher = get_tree().root.get_node("Main/Dispatcher")
	units = get_tree().root.get_node("Main/Units")
	zero_target()
	self.connect("left_click",
		player,
		"_on_Unit_left_click")

func load_stats(unit_type):
	set_module_refs()
	display_name = units.statlines[unit_type]["display name"]
	speed = units.statlines[unit_type]["speed"]
	health = units.statlines[unit_type]["health"]
	attack = units.statlines[unit_type]["attack"]
	attack_range = units.statlines[unit_type]["range"]
	set_icons(unit_type)

func is_boxable():
	return true


func set_icons(unit_type):
	$UpSprite.texture = units.icons[unit_type][0]
	$UpRightSprite.texture = units.icons[unit_type][1]
	$RightSprite.texture = units.icons[unit_type][2]
	$DownRightSprite.texture = units.icons[unit_type][3]
	$DownSprite.texture = units.icons[unit_type][4]
	$DownLeftSprite.texture = units.icons[unit_type][5]
	$LeftSprite.texture = units.icons[unit_type][6]
	$UpLeftSprite.texture = units.icons[unit_type][7]

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

func _process(delta):
	if target_entity != null:
		# Check if our target moved and repath if so
		if target_entity.position != final_target:
			path_to(target_entity.get_center())
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
	var movement = speed * direction * delta
	move_and_collide(movement)
	
	# set animation / sprite based on last direction modulo current direction
	if direction != last_direction:
		get_facing()
	
	last_direction = direction

func get_center():
	return Vector2(position.x, position.y + 3)

func zero_target():
	final_target = position
	direction = Vector2(0, 0)
	path = []
	step_target = position

func get_step_target():
	var new_step_target = nav.map_to_world(path[0])
	path.remove(0)
	step_target = Vector2(new_step_target.x, new_step_target.y + 32)
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
	$SelectionBox.visible = true
	$HealthBarGreen.visible = true
	$HealthBarRed.visible = true

func deselect():
	selected = false
	$SelectionBox.visible = false
	$HealthBarGreen.visible = false
	$HealthBarRed.visible = false

func _on_BBox_mouse_entered():
	emit_signal("hovered")

	$SelectionBox.visible = true
	$HealthBarGreen.visible = true
	$HealthBarRed.visible = true


func _on_BBox_mouse_exited():
	emit_signal("unhovered")
	if not selected:
		$SelectionBox.visible = false
		$HealthBarGreen.visible = false
		$HealthBarRed.visible = false


func _on_BBox_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("left_click"):
		emit_signal("left_click", self)
	elif event.is_action_pressed("right_click"):
		emit_signal("right_click", self)
