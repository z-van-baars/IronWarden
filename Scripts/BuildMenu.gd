extends Control
var active_structure = null
var build_button_scn = preload("res://Scenes/UI/BuildButton.tscn")
var tech_button_scn = preload("res://Scenes/UI/BuildButton.tscn")
var player
var units


func _ready():
	player = get_tree().root.get_node("Main/Player")
	units = get_tree().root.get_node("Main/Player")
	clear_all()

func clear_all():
	active_structure = null
	for child in $Panel/ButtonGrid.get_children():
		child.queue_free()
	hide()

func set_references():
	for unit in active_structure.build_options:
		var new_button = build_button_scn.instance()
		$Panel/ButtonGrid.add_child(new_button)
		new_button.set_references()
		new_button.load_build_unit(unit)
		new_button.connect_signals(self)

	for tech in active_structure.tech_options:
		pass

func _on_Structure_selected(structure):
	active_structure = structure
	set_references()
	show()

func _on_Structure_deselected():
	clear_all()

func check_cost(resource_cost):
	for resource in resource_cost:
		if player.resource < resource_cost[resource]:
			return false
	return true

func _on_Build_button_clicked(unit_type):
	if check_cost(units.statlines[unit_type]["cost"]) == true:
		active_structure.spawn_unit(unit_type)
		player.debit_resources(units.statlines[unit_type]["cost"])
	else:
		pass
		

