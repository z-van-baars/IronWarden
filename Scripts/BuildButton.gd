extends Control
signal clicked
var units

var unit_name = "None"
var unit_cost = {}

func set_references():
	units = get_tree().root.get_node("Main/Units")

func connect_signals(build_menu_node):
	self.connect(
		"clicked",
		build_menu_node,
		"_on_Build_Button_clicked")
func load_build_unit(build_unit):
	unit_name = build_unit
	unit_cost = units.statlines[build_unit]["cost"]
	for resource in unit_cost:
		if unit_cost[resource] != 0:
			hint_tooltip += str(unit_cost[resource])
			hint_tooltip += " "
			hint_tooltip += resource
			hint_tooltip += "\n"


func _on_Button_pressed():
	emit_signal("clicked", unit_name)
