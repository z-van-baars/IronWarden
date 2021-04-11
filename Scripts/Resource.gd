extends Node2D
signal hovered
var resources
var tools
var dispatcher
var pos : Vector2


var resource_stocks = {
	"Biomass": 0,
	"Minerals": 0,
	"Alloy": 0,
	"Energy": 0}

func _ready():
	resources = get_tree().root.get_node("Main/Resources")
	tools = get_tree().root.get_node("Main/Tools")
	dispatcher = get_tree().root.get_node("Main/Dispatcher")

func load_type(deposit_type, tile_coordinates):
	pos = tile_coordinates
	for resource_type in resources.deposits[deposit_type]:
		resource_stocks[resource_type] = resources.deposits[deposit_type][resource_type]
	$Sprite.texture = tools.r_choice(resources.icons[deposit_type])
	
func _process(delta):
	check_expire()

func is_boxable():
	return false

func increment(resource_type, quantity):
	resource_stocks[resource_type] += quantity
	
func check_expire():
	for count in resource_stocks.values():
		if count > 0:
			return
	kill()

func kill():
	queue_free()



func _on_Area2D_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("right_click"):
		$Border.modulate = Color(0, 155, 0)
		$Border.show()
