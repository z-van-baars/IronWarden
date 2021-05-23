extends Control
signal tick1
signal structure_button_clicked
signal exit

var player
var st
var dis
var structure_type = null
var structure_button_scn = preload("res://Scenes/UI/ConstructionButton.tscn")


func new_game():
	player = get_tree().root.get_node("Main").local_player
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	dis = get_tree().root.get_node("Main/Dispatcher")
	clear_all()


func clear_all():
	for child in $Panel/ButtonGrid.get_children():
		child.queue_free()
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
	for structure in player.get_construction_options():
		var new_button = structure_button_scn.instance()
		$Panel/ButtonGrid.add_child(new_button)
		new_button.setup(self, structure)

func _on_Dispatcher_selection_cleared():
	clear_all()

func _on_StructureButton_clicked(s_type):
	structure_type = s_type
	if check_cost(st.get_cost(structure_type)) == true:
		emit_signal("tick1")
		$Panel/ButtonGrid.hide()
		$CancelButton.show()
		emit_signal("structure_button_clicked", structure_type)
	else:
		pass

func get_structure_type():
	return structure_type


func _on_CancelButton_pressed():
	emit_signal("cancel_clicked", dis, "_on_Construction_Menu_Cancel_clicked")
	$Panel/ButtonGrid.show()
	$CancelButton.hide()


func _on_Dispatcher_open_construction_menu():
	if visible: return
	construct_buttons()
	show()
	$Panel/ButtonGrid.show()
	$CancelButton.hide()


func _on_ExitButton_pressed():
	clear_all()
	emit_signal("exit")


func _on_Dispatcher_structure_placement_right_click():
	_on_CancelButton_pressed()
