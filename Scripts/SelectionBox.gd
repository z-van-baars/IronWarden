extends Node2D

signal selection_box_end

onready var local_player
var selected_units = []

var start = Vector2.ZERO
var stop = Vector2.ZERO

var top_left = Vector2.ZERO
var bottom_right = Vector2.ZERO

var selection_rect = RectangleShape2D.new()

func connect_local_player():
	local_player = get_tree().root.get_node("Main").local_player
	self.connect(
		"selection_box_end",
		local_player,
		"_on_Selection_Box_end"
	)

func reset():
	# $Area2D/CollisionShape2D.disabled = true
	$Timer.stop()
	$CloseTimer.stop()

func start_box(mouse_pos):
	start = mouse_pos
	$Timer.start()
	#$Area2D/CollisionShape2D.disabled = false
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
	
	set_area()


func set_area():
	selection_rect.extents = (start - stop) / 2

func close_box():
	selected_units = []
	if not check_timer():
		hide()
		reset()
		return
	var space = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape($Area2D/CollisionShape2D.shape)
	query.transform = Transform2D(0, (stop + start) / 2)
	var covered_units = space.intersect_shape(query)
	for entry in covered_units:
		if entry.collider.is_boxable():
			selected_units.append(entry.collider)
	emit_signal("selection_box_end", selected_units)
	hide()
	reset()

func close_box_new():
	if not check_timer():
		hide()
		reset()
		return
	selected_units = []
	$Area2D/CollisionShape2D.disabled = false
	$CloseTimer.start()

func _on_CloseTimer_timeout():
	print($Area2D.get_overlapping_areas())
	print($Area2D.get_overlapping_bodies())
	print(selected_units)
	if not selected_units.empty():
		emit_signal("selection_box_end", selected_units)
	$Area2D/CollisionShape2D.disabled = true
	hide()
	reset()


func _on_Area2D_body_entered(body):
	# Hits for Deposits
	# Hits for Selection Border
	selected_units.append(body)


func _on_Area2D_area_entered(area):
	#This one
	selected_units.append(area)

func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	selected_units.append(area)


func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	selected_units.append(body)
