extends KinematicBody2D

# Signal Declarations
signal left_clicked
signal right_clicked
signal hovered
signal unhovered
signal production_building_selected
signal selected
signal deselected

# Module References
var tools
var nav
var nav2d
var player
var dis
var units
var structures
onready var unit_scn = preload("res://Scenes/Unit.tscn")
onready var center_widget = get_tree().root.get_node("Main/UILayer/ScreenArea/CenterWidget")

# mutable internal properties
var can_path = false
var selected = false
var target_entity = null
var state = "Idle"
var rally_point = position
var pos : Vector2


# variable statline properties, filled out for different units programmatically
var has_build_menu = false
var build_options = []
var tech_options = []
var width = 1
var height = 1
var display_name
var armor
var health
var maxhealth
var shields
var maxshields
var attack
var attack_range
var build_queue = []

func _ready():
	set_module_refs()

func _process(delta):
	update_display_bars()

func set_module_refs():
	tools = get_tree().root.get_node("Main/Tools")
	nav = get_tree().root.get_node("Main/Nav2D/NavMap")
	nav2d = get_tree().root.get_node("Main/Nav2D")
	player = get_tree().root.get_node("Main/Player")
	units = get_tree().root.get_node("Main/Units")
	dis = get_tree().root.get_node("Main/Dispatcher")
	structures = get_tree().root.get_node("Main/Structures")
	self.connect("left_click", player, "_on_Unit_left_click")
	self.connect("hovered", dis, "_on_Unit_hovered")
	self.connect("unhovered", dis, "_on_Unit_unhovered")
	self.connect("selected", dis, "_on_Production_Structure_selected")
	self.connect("selected", dis, "_on_Unit_selected")
	self.connect("deselected", dis, "_on_Unit_deselected")

func load_stats(structure_type, tile_coordinates):
	var _stats = structures.statlines[structure_type]
	pos = tile_coordinates
	display_name = _stats["display name"]
	armor = _stats["armor"]
	health = _stats["maxhealth"]
	maxhealth = _stats["maxhealth"]
	shields = _stats["maxshields"]
	maxshields = _stats["maxshields"]
	attack = _stats["attack"]
	attack_range = _stats["range"]
	if display_name in structures.build_options.keys():
		build_options = structures.build_options[display_name]
	if display_name in structures.tech_options.keys():
		tech_options = structures.tech_options[display_name]
	set_icon(structure_type)
	set_display_bars()

func set_display_bars():
	if maxshields == 0:
		$ShieldBar.hide()
	$BuildBar.value = 0
	$BuildBar.hide()

func update_display_bars():
	if build_queue != []:
		$BuildBar.show()
		$BuildBar.value = 100 - ($BuildTimer.time_left / $BuildTimer.wait_time) * 100
	$HealthBar.value = (health / maxhealth) * 100

func is_boxable():
	return true


func set_icon(structure_type):
	$Sprite.texture = structures.icons[structure_type]


func set_rally_point(location):
	rally_point = location

func get_center():
	return Vector2(position.x, position.y + 8)

func spawn_unit(unit_type):
	units.add_unit(unit_type, position + tools.circ_random(get_center(), 50))

func add_to_queue(unit_type):
	if build_queue == []:
		$BuildTimer.wait_time = units.statlines[unit_type]["build time"]
		$BuildTimer.start()
	build_queue.append(unit_type)

func select():
	selected = true
	$SelectionBox.visible = true
	$HealthBar.visible = true
	emit_signal("selected", self)

func deselect():
	selected = false
	$SelectionBox.visible = false
	$HealthBar.visible = false
	emit_signal("deselected")

func _on_BBox_mouse_entered():
	emit_signal("hovered", self)

	$SelectionBox.visible = true
	$HealthBar.visible = true

func _on_BBox_mouse_exited():
	emit_signal("unhovered")
	if not selected:
		$SelectionBox.visible = false
		$HealthBar.visible = false


func _on_BBox_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("left_click"):
		emit_signal("left_clicked", self)
		if build_options != [] or tech_options != []:
			emit_signal("selected", self, build_options, tech_options)
	elif event.is_action_pressed("right_clicked"):
		emit_signal("right_clicked", self)


func _on_BuildTimer_timeout():
	spawn_unit(build_queue.pop_front())
	if build_queue == []:
		$BuildTimer.stop()
		$BuildBar.hide()
	else:
		$BuildTimer.wait_time = units.statlines[build_queue[0]]["build time"]
		$BuildTimer.start()
	
