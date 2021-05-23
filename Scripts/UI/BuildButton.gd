extends Control
signal clicked
var units
var res

var unit_type = null
var resource_cost = {}

func setup(build_menu_node, unit):
	set_references()
	connect_signals(build_menu_node)
	load_build_unit(unit)

func connect_signals(build_menu_node):
	self.connect(
		"clicked",
		build_menu_node,
		"_on_Build_Button_clicked")

func load_build_unit(build_unit):
	var _stats = units.statlines[build_unit]
	unit_type = build_unit
	resource_cost = units.get_build_cost(unit_type)
	hint_tooltip = "Build " + units.get_display_name(unit_type) + "\n"
	for resource in resource_cost:
		if resource_cost[resource] != 0:
			hint_tooltip += str(resource_cost[resource])
			hint_tooltip += " "
			hint_tooltip += res.string_from_id(resource)
			hint_tooltip += " "
	$Button.text = units.get_display_name(unit_type)[0].capitalize()
	$Button/Thumbnail.texture = units.thumbnail[unit_type]

func spacer_setup():
	# My god this is a hack and I hate it but it also works and is kinda elegant
	modulate = Color(0, 0, 0, 0)

func set_references():
	units = get_tree().root.get_node("Main/GameObjects/Units")
	res = get_tree().root.get_node("Main/GameObjects/Resources")

func disable_button():
	modulate = Color(4.0, 1.0, 0.3)
	
func enable_button():
	modulate = Color(1, 1, 1)



func _on_Button_pressed():
	emit_signal("clicked", unit_type)
