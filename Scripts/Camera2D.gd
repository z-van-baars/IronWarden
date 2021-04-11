extends Camera2D


var scroll_x = 0
var scroll_y = 0
var scroll_speed = 500

var scrolling = false
var scroll_offset = Vector2(0, 0)
var shake_amount = 2.0
var shaking = false

func _process(delta):
	if shaking == true:
		set_offset(Vector2( \
			rand_range(-1.0, 1.0) * shake_amount, \
			rand_range(-1.0, 1.0) * shake_amount \
		))
	position += Vector2(scroll_x, scroll_y) * delta

func _input(event):
	if event.is_action_pressed("ui_w"):
		scroll_y -= scroll_speed
	elif event.is_action_pressed("ui_a"):
		scroll_x -= scroll_speed
	elif event.is_action_pressed("ui_d"):
		scroll_x += scroll_speed
	elif event.is_action_pressed("ui_s"):
		scroll_y += scroll_speed
	elif event.is_action_released("ui_w"):
		scroll_y += scroll_speed
	elif event.is_action_released("ui_s"):
		scroll_y -= scroll_speed
	elif event.is_action_released("ui_a"):
		scroll_x += scroll_speed
	elif event.is_action_released("ui_d"):
		scroll_x -= scroll_speed


	elif event.is_action_pressed("right_click") and get_parent().selected_units == []:
		scrolling = true
		scroll_offset = get_viewport().get_mouse_position() + position
		
	elif event.is_action_released("right_click"):
		scrolling = false

	elif event is InputEventMouseMotion:
		if scrolling == true:
			var mouse_pos = get_viewport().get_mouse_position()
			position = scroll_offset - mouse_pos
	

func center_on_tile(tile_coords):
	var screen_coords = get_tree().root.get_node("Main/GameMap/TileMap").map_to_world(tile_coords)
	screen_coords -= Vector2(32, 16)
	position = screen_coords - offset

func center_on_coordinates(screen_coords):
	screen_coords -= Vector2(32, 16)
	position = screen_coords - offset

func _on_shake_catalyst(override_amount=2.0, override_duration=0.1):
	shake_amount = override_amount
	$ShakeTimer.wait_time = override_duration
	$ShakeTimer.start()
	shaking = true

func _on_ShakeTimer_timeout():
	shaking = false
