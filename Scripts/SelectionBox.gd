extends Node2D

signal selection_box_end

onready var local_player
var active_query = null
var active_physics_space = null
var covered_units = []
var start = Vector2.ZERO
var stop = Vector2.ZERO

var top_left = Vector2.ZERO
var bottom_right = Vector2.ZERO
	

func connect_local_player():
	local_player = get_tree().root.get_node("Main").local_player
	self.connect(
		"selection_box_end",
		local_player,
		"_on_Selection_Box_end"
	)

func reset():
	covered_units = []
	active_query = null
	start = Vector2.ZERO
	stop = Vector2.ZERO
	top_left = Vector2.ZERO
	bottom_right = Vector2.ZERO
	$Timer.stop()

func start_box(mouse_pos):
	$Area2D.monitoring = true
	start = mouse_pos
	$Timer.start()
	active_physics_space = get_world_2d().direct_space_state
	active_query = Physics2DShapeQueryParameters.new()
	active_query.set_shape($Area2D/CollisionShape2D.shape)
	active_query.set_collision_layer(1)
	active_query.collide_with_areas = true
	active_query.collide_with_bodies = false
	show()
	

func check_timer():
	return $Timer.is_stopped()

func _process(_delta):
	stop = get_viewport().get_canvas_transform().xform_inv(get_viewport().get_mouse_position())
	var size = get_viewport().get_canvas_transform().xform_inv(get_viewport().get_mouse_position()) - start
	
	if size[0] < 0 and size[1] < 0:
		# Top Left
		$Panel.rect_size = start - stop
		$Panel.rect_position = stop
	elif size[0] < 0 and size[1] >= 0:
		# Bottom Left
		$Panel.rect_size = Vector2(
			start[0] - stop[0],
			stop[1] - start[1])
		$Panel.rect_position = Vector2(stop[0], start[1])
	elif size[0] >= 0 and size[1] < 0:
		#Top right
		$Panel.rect_size = Vector2(
			stop[0] - start[0],
			start[1] - stop[1])
		$Panel.rect_position = Vector2(start[0], stop[1])
	elif size[0] >= 0 and size[1] >= 0:
		#Bottom Right
		$Panel.rect_size = stop - start
		$Panel.rect_position = start
	top_left = $Panel.rect_position
	bottom_right = $Panel.rect_size + $Panel.rect_position
	$Area2D/CollisionShape2D.position = $Panel.rect_position + $Panel.rect_size / 2 + Vector2(0, 1)
	$Area2D/CollisionShape2D.shape.extents = $Panel.rect_size.abs() / 2 + Vector2(0, 1)
	if $Area2D.monitoring:
		set_query_transform()


func set_query_transform():
	active_query.transform = Transform2D(0, (stop + start) / 2)
	covered_units = active_physics_space.intersect_shape(active_query)

func close_box():
	var selected_units = []
	if not $Timer.is_stopped():
		$Area2D.monitoring = false
		hide()
		reset()
		return
	for entry in covered_units:
		if not entry.collider.get_collision_layer_bit(0):
			continue
		if entry.collider.get_parent().is_boxable():
			selected_units.append(entry.collider.get_parent())
	emit_signal("selection_box_end", selected_units)
	hide()
	$Area2D.monitoring = false
	reset()

func _on_Area2D_area_entered(area):
	#This one
	print(area.get_parent())
