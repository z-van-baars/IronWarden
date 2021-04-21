extends Control
signal play_tick_1

var player
var st
var structure_button_scn = preload("res://Scenes/UI/StructureButton.tscn")

var builders


func _ready():
	player = get_tree().root.get_node("Main/Player")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	clear_all()


func clear_all():
	for child in $Panel/ButtonGrid.get_children():
		child.queue_free()
	builders = []
	hide()

func check_cost(resource_cost):
	for resource in resource_cost.keys():
		if player.resources[resource] < resource_cost[resource]:
			return false
	return true

func set_cost_modulators():
	for build_button in $Panel/ButtonGrid.get_children():
		build_button.enable_button()
		if check_cost(build_button.resource_cost) == false:
			build_button.disable_button()

func construct_buttons():
	for structure in player.construction_options:
		var new_button = structure_button_scn.instance()
		$Panel/ButtonGrid.add_child(new_button)
		new_button.setup(self, structure)

func _on_Structure_Button_clicked(structure_type):
	if check_cost(st.statlines[structure_type]["cost"]) == true:
		emit_signal("play_tick_1")
	else:
		pass

func _on_Dispatcher_builder_unit_selected(builder_units):
	builders = builder_units
	construct_buttons()
	show()


func _on_Dispatcher_selection_cleared():
	clear_all()
