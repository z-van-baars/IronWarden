extends Camera2D

# Lower cap for the `_zoom_level`.
export var min_zoom := 0.5
# Upper cap for the `_zoom_level`.
export var max_zoom := 2.0
# Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
export var zoom_factor := 0.1
# Duration of the zoom's tween animation.
export var zoom_duration := 0.2

# The camera's target zoom level.
var _zoom_level := 1.0 setget _set_zoom_level

# We store a reference to the scene's tween node.
onready var tween: Tween = $Tween
var main
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

func _set_zoom_level(value: float) -> void:
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, min_zoom, max_zoom)
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	# to the target zoom level.
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(_zoom_level, _zoom_level),
		zoom_duration,
		tween.TRANS_SINE,
		# Easing out means we start fast and slow down as we reach the target value.
		tween.EASE_OUT
	)
	tween.start()

func _input(event):
	if event.is_action_pressed("K_w"):
		scroll_y -= scroll_speed
	elif event.is_action_pressed("K_a"):
		scroll_x -= scroll_speed
	elif event.is_action_pressed("K_d"):
		scroll_x += scroll_speed
	elif event.is_action_pressed("K_s"):
		scroll_y += scroll_speed
	elif event.is_action_released("K_w"):
		scroll_y += scroll_speed
	elif event.is_action_released("K_s"):
		scroll_y -= scroll_speed
	elif event.is_action_released("K_a"):
		scroll_x += scroll_speed
	elif event.is_action_released("K_d"):
		scroll_x -= scroll_speed
	
	elif event.is_action_pressed("backspace"):
		_set_zoom_level(1)


	elif event.is_action_pressed("right_click") and get_parent().get_selected() == []:
		scrolling = true
		scroll_offset = get_viewport().get_mouse_position() + position
		
	elif event.is_action_released("right_click"):
		scrolling = false

	elif event is InputEventMouseMotion:
		if scrolling == true:
			var mouse_pos = get_viewport().get_mouse_position()
			position = scroll_offset - mouse_pos
			

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		# Inside a given class, we need to either write `self._zoom_level = ...` or explicitly
		# call the setter function to use it.
		_set_zoom_level(_zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level + zoom_factor)
	

func center_on_tile(tile_map, tile_coords):
	var screen_coords = tile_map.map_to_world(tile_coords)
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
