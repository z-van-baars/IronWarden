extends Node2D
signal left_clicked
signal right_clicked
signal hovered
signal unhovered
signal kill

onready var display_name
onready var health
onready var maxhealth
onready var starting = {}
onready var remaining = {}
onready var r_type

onready var tools
onready var dis
onready var res
onready var pos : Vector2 # tile coordinate pair
var gatherers = []
onready var partially_mined = false
onready var selected = false

func _ready():

	tools = get_tree().root.get_node("Main/Tools")
	dis = get_tree().root.get_node("Main/Dispatcher")
	res = get_tree().root.get_node("Main/GameObjects/Resources")

func connect_signals():
	connect("left_clicked", dis, "_on_Resource_left_clicked")
	connect("right_clicked", dis, "_on_Resource_right_clicked")
	connect("hovered", dis, "_on_Resource_hovered")
	connect("unhovered", dis, "_on_Resource_unhovered")

func setup(deposit_type, tile_coordinates, location):
	connect_signals()
	starting = {
		res.ResourceTypes.BIOMASS: 0,
		res.ResourceTypes.ALLOY: 0,
		res.ResourceTypes.WARPSTONE: 0,
		res.ResourceTypes.ENERGY: 0}

	remaining = {
		res.ResourceTypes.BIOMASS: 0,
		res.ResourceTypes.ALLOY: 0,
		res.ResourceTypes.WARPSTONE: 0,
		res.ResourceTypes.ENERGY: 0}
	load_type(deposit_type)
	pos = tile_coordinates
	position = location


	assert(res.deposits[deposit_type][r_type] != 0)


func load_type(deposit_type):
	r_type = res.get_r_type(deposit_type)
	display_name = res.get_display_name(deposit_type)
	health = 100
	maxhealth = 100
	starting[r_type] = res.deposits[deposit_type][r_type]
	remaining[r_type] = res.deposits[deposit_type][r_type]
	
	$Sprite.texture = tools.r_choice(res.deposit_icons[deposit_type])
	$ProgressBar.min_value = 0
	$ProgressBar.max_value = starting[r_type]
	
func _process(delta):
	if partially_mined:
		$ProgressBar.show()
	$ProgressBar.value = remaining[r_type]
	check_expire()

func is_boxable():
	return false

func increment(resource_type, quantity):
	partially_mined = true
	if remaining[resource_type] >= quantity:
		remaining[resource_type] -= quantity
		return
	remaining[resource_type] = 0
	
func check_expire():
	for count in remaining.values():
		if count > 0: return
	kill()

func get_display_name(): return display_name

func get_health(): return health

func get_maxhealth(): return maxhealth

func get_center():
	return Vector2(position.x, position.y + 16)

func kill():
	emit_signal("kill")
	queue_free()

func select():
	selected = true
	$SelectionBox.show()
	$ProgressBar.show()

func deselect():
	selected = false
	$SelectionBox.hide()
	$ProgressBar.hide()

func confirm():
	return

func gather_target_set(gatherer):
	$SelectionBox.modulate = Color(255, 0, 0)
	$SelectionBox.show()
	$FlashTimer.start()
	gatherers.append(gatherer)
	connect("kill", gatherer, "_on_Target_Resource_kill")

func gather_target_unset(gatherer):
	$SelectionBox.modulate = Color(255, 255, 255)
	if not selected:
		$SelectionBox.hide()
	if not partially_mined: $ProgressBar.hide()
	connect("kill", gatherer, "_on_Target_Resource_kill")
	gatherers.erase(gatherer)


func _on_BBox_input_event(viewport, event, shape_idx):
	if event.is_action_released("left_click"):
		emit_signal("left_clicked", self)
	elif event.is_action_pressed("right_click"):
		emit_signal("right_clicked", self)

func _on_BBox_mouse_entered():
	$ProgressBar.show()
	$SelectionBox.show()
	emit_signal("hovered", self)

func _on_BBox_mouse_exited():
	if not selected:
		$ProgressBar.hide()
		$SelectionBox.hide()
	emit_signal("unhovered")


func _on_FlashTimer_timeout():
	$SelectionBox.modulate = Color(255, 255, 255)
	if not selected:
		$SelectionBox.hide()
