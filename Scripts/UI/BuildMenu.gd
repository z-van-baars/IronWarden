extends Control
signal play_tick_1

var active_structure = null
var build_button_scn = preload("res://Scenes/UI/BuildButton.tscn")
var tech_button_scn = preload("res://Scenes/UI/BuildButton.tscn")
var player
var units


func _ready():
	player = get_tree().root.get_node("Main/Player")
	units = get_tree().root.get_node("Main/GameObjects/Units")
	clear_all()

func _process(delta):
	set_cost_modulators()

func clear_all():
	active_structure = null
	for child in $Panel/ButtonGrid.get_children():
		child.queue_free()
	hide()


func set_cost_modulators():
	for build_button in $Panel/ButtonGrid.get_children():
		build_button.enable_button()
		if check_cost(build_button.resource_cost) == false:
			build_button.disable_button()


func construct_buttons():
	for unit in active_structure.build_options:
		var new_button = build_button_scn.instance()
		$Panel/ButtonGrid.add_child(new_button)
		new_button.setup(self, unit)

	for tech in active_structure.tech_options: pass

func check_cost(resource_cost):
	for resource in resource_cost.keys():
		if player.resources[resource] < resource_cost[resource]:
			return false
	return true

func _on_Build_Button_clicked(unit_type):
	if check_cost(units.get_build_cost(unit_type)) == true:
		emit_signal("play_tick_1")
		active_structure.add_to_queue(unit_type)
		player.debit_resources(units.get_build_cost(unit_type), unit_type)
	else:
		pass

func _on_Dispatcher_open_build_menu(structure):
	active_structure = structure
	construct_buttons()
	show()

func _on_Dispatcher_selection_cleared():
	clear_all()
