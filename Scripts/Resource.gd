extends Node2D
signal hovered
signal unhovered
signal selected
signal deselected
signal right_clicked

var res
var tools
var dis
var pos : Vector2
var hovered = false
var partially_mined = false
var r_type = ""
var starting = {
	"Biomass": 0,
	"Minerals": 0,
	"Alloy": 0,
	"Energy": 0}
var remaining = {
	"Biomass": 0,
	"Minerals": 0,
	"Alloy": 0,
	"Energy": 0}

func _ready():
	res = get_tree().root.get_node("Main/Resources")
	tools = get_tree().root.get_node("Main/Tools")
	dis = get_tree().root.get_node("Main/Dispatcher")

func connect_signals():
	connect("right_clicked", dis, "_on_Resource_right_clicked")

func setup(deposit_type, tile_coordinates):
	pos = tile_coordinates
	load_type(deposit_type)
	connect_signals()


func load_type(deposit_type):
	for resource_type in res.deposits[deposit_type]:
		starting[resource_type] = res.deposits[deposit_type][resource_type]
		remaining[resource_type] = res.deposits[deposit_type][resource_type]
	$Sprite.texture = tools.r_choice(res.icons[deposit_type])
	
func _process(delta):
	if hovered == true or partially_mined == true:
		$ProgressBar.show()
		$ProgressBar.value = (remaining[r_type] / starting[r_type]) * 100
		check_expire()
	$ProgressBar.hide()

func is_boxable():
	return false

func increment(resource_type, quantity):
	if quantity >= remaining[resource_type]:
		remaining[resource_type] += quantity
	remaining[resource_type] = 0
	
func check_expire():
	for count in remaining.values():
		if count > 0:
			return
	kill()

func kill():
	queue_free()

func _on_BBox_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("right_clicked"):
		$Border.modulate = Color(0, 155, 0)
		$Border.show()
		emit_signal("right_clicked", self)
	elif event.is_action_pressed("left_click"):
		print("left click")
		


func _on_BBox_mouse_entered():
	$ProgressBar.show()


func _on_BBox_mouse_exited():
	$ProgressBar.hide()
