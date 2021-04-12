extends Control
signal clicked
var units

var unit_name = "None"
var resource_cost = {}

func setup(build_menu_node, unit):
	set_references()

	load_build_unit(unit)
	connect_signals(build_menu_node)

func spacer_setup():
	# My god this is a hack and I hate it but it also works and is kinda elegant
	modulate = Color(0, 0, 0, 0)

func set_references():
	units = get_tree().root.get_node("Main/Units")

func disable_button():
	modulate = Color(10.0, 0.8, 0.8)
	
func enable_button():
	modulate = Color(1, 1, 1)

func connect_signals(build_menu_node):
	self.connect(
		"clicked",
		build_menu_node,
		"_on_Build_Button_clicked")

func load_build_unit(build_unit):
	unit_name = build_unit
	resource_cost = units.statlines[build_unit]["cost"]
	for resource in resource_cost:
		if resource_cost[resource] != 0:
			hint_tooltip = "Build " + build_unit + "\n"
			hint_tooltip += str(resource_cost[resource])
			hint_tooltip += " "
			hint_tooltip += resource
			hint_tooltip += "\n"
	$Button.text = build_unit[0].capitalize()


func _on_Button_pressed():
	emit_signal("clicked", unit_name)
