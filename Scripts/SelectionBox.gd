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
	$Panel.rect_position = Vector2.ZERO
	$Timer.stop()
	selected_units = []
	hide()

func start_box(mouse_pos):
	start = mouse_pos
	$Timer.start()
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
	
	set_area()


func set_area():
	# $Area2D/Borders.position = $Panel.rect_position + $Panel.rect_size / 2
	# $Area2D/Borders.shape.extents = $Panel.rect_size / 2
	selection_rect.extents = (start - stop) / 2

func close_box():
	if not check_timer():
		reset()
		return
	var space = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(selection_rect)
	query.transform = Transform2D(0, (stop + start) / 2)
	var covered_units = space.intersect_shape(query)
	for entry in covered_units:
		if entry.collider.is_boxable(): selected_units.append(entry.collider)
	emit_signal("selection_box_end", selected_units)
	hide()
	reset()
