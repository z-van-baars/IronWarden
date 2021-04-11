extends KinematicBody2D

# Signal Declarations
signal left_click
signal right_click
signal selected
signal deselected

# Module References
var tools
var nav
var nav2d
var player
var dispatcher
var units
var structures
onready var unit_scn = preload("res://Scenes/Unit.tscn")

# mutable internal properties
var can_path = false
var selected = false
var target_entity = null
var state = "Idle"
var rally_point = position
var pos : Vector2


# variable statline properties, filled out for different units programmatically
var has_build_menu = false
var build_options = {}
var tech_options = {}
var width = 1
var height = 1
var display_name
var health
var attack
var attack_range
var build_queue = []

func _ready():
	set_module_refs()

func set_module_refs():
	tools = get_tree().root.get_node("Main/Tools")
	nav = get_tree().root.get_node("Main/Nav2D/NavMap")
	nav2d = get_tree().root.get_node("Main/Nav2D")
	player = get_tree().root.get_node("Main/Player")
	dispatcher = get_tree().root.get_node("Main/Dispatcher")
	structures = get_tree().root.get_node("Main/Structures")
	self.connect("left_click",
		player,
		"_on_Unit_left_click")
	self.connect("selected",
		dispatcher,
		"_on_Build_Structure_selected")
	self.connect("deselected",
		dispatcher,
		"_on_Build_Structure_deselected")

func load_stats(structure_type, tile_coordinates):
	pos = tile_coordinates
	display_name = structures.statlines[structure_type]["display name"]
	health = structures.statlines[structure_type]["health"]
	attack = structures.statlines[structure_type]["attack"]
	attack_range = structures.statlines[structure_type]["range"]
	if display_name in structures.build_options.keys():
		build_options = structures.build_options[display_name]
	if display_name in structures.tech_options.keys():
		tech_options = structures.tech_options[display_name]
	set_icon(structure_type)

func is_boxable():
	return true


func set_icon(structure_type):
	$Sprite.texture = structures.icons[structure_type]


func set_rally_point(location):
	rally_point = location

func get_center():
	return Vector2(position.x, position.y + 3)

func spawn_unit(unit_type):
	var new_unit = unit_scn.instance()
	units.add_child(new_unit)
	new_unit.position = tools.circ_random(get_center(), 100)
	new_unit.load_stats(unit_type)
	if rally_point != position:
		new_unit.set_target(rally_point)
	

func select():
	selected = true
	$SelectionBox.visible = true
	$HealthBarGreen.visible = true
	$HealthBarRed.visible = true
	emit_signal("selected", self)

func deselect():
	selected = false
	$SelectionBox.visible = false
	$HealthBarGreen.visible = false
	$HealthBarRed.visible = false
	emit_signal("deselected")

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
		if build_options != {} or tech_options != {}:
			emit_signal("selected", build_options, tech_options)
	elif event.is_action_pressed("right_click"):
		emit_signal("right_click", self)


func _on_BuildTimer_timeout():
	build_queue[0]
