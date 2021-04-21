extends Node2D

signal toggle_debug_menu
signal toggle_spawn_mode
signal resources_changed
signal unit_selected
signal resource_selected
signal selection_cleared
signal unit_move_to


var res
var units
var st

var unit_scn

onready var dragging = false
onready var selected_units = []
onready var spawn_mode = get_tree().root.get_node("Main").spawn_mode
onready var last_clicked = null
onready var selection_box = get_tree().root.get_node("Main/SelectionBox")

onready var resources

onready var construction_options = []


func _ready():
	set_module_refs()
	for each in selected_units:
		each.selected = true


func set_module_refs():
	res = get_tree().root.get_node("Main/GameObjects/Resources")
	units = get_tree().root.get_node("Main/GameObjects/Units")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	unit_scn = preload("res://Scenes/Unit.tscn")

func set_initial_construction_options():
	construction_options = [
		st.StructureTypes.STRUCT_COMMAND_POST,
		st.StructureTypes.STRUCT_BIOMASS_REACTOR,
		st.StructureTypes.STRUCT_ALLOY_FOUNDRY,
		st.StructureTypes.STRUCT_WARPSTONE_REFINERY,
		st.StructureTypes.STRUCT_ENERGY_CONDUIT
	]

func set_initial_resources():
	resources = {
		res.ResourceTypes.BIOMASS: 200,
		res.ResourceTypes.ALLOY: 600,
		res.ResourceTypes.WARPSTONE: 0,
		res.ResourceTypes.ENERGY: 100,
		res.ResourceTypes.COMMAND: 0
	}


func clear_selected():
	for each in selected_units:
		each.deselect()
	selected_units = []
	emit_signal("selection_cleared")

func _unhandled_input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
	if event.is_action_pressed("~"):
		emit_signal("toggle_debug_menu")
	if event.is_action_pressed("ui_space"):
		if selected_units != []:
			$Camera2D.center_on_coordinates(selected_units[0].get_center())
	if event.is_action_pressed("spawn_mode"):
		spawn_mode = true
		emit_signal("toggle_spawn_mode")
	if event.is_action_released("spawn_mode"):
		spawn_mode = false
		emit_signal("toggle_spawn_mode")
		
	if event.is_action_pressed("left_click"):
		clear_selected()
		selection_box.start(get_viewport().get_canvas_transform().xform_inv(get_viewport().get_mouse_position()))
	if event.is_action_released("left_click"):
		selection_box.close()

		if spawn_mode == true:
			var new_unit = unit_scn.instance()
			units.add_child(new_unit)
			new_unit.position = get_viewport().get_canvas_transform().xform_inv(get_viewport().get_mouse_position())
			new_unit.load_stats("Rhino")

	if event.is_action_pressed("right_click") and !selected_units.empty():
		var click_loc = get_viewport().get_canvas_transform().xform_inv(event.position * $Camera2D._zoom_level)
		selected_units[0].confirm()
		for each in selected_units:
			if "can_path" in each and each.can_path:
				each.path_to(click_loc)
				each.set_task_idle()
				emit_signal("unit_move_to", click_loc)
				
			elif "build_options" in each:
				each.set_rally_point(click_loc)
				emit_signal("unit_move_to", click_loc)


func _on_Selection_Box_end(newly_selected):
	clear_selected()
	if newly_selected.empty(): return
	for each in newly_selected:
		selected_units.append(each)
		each.select()
	emit_signal("unit_selected", selected_units[0])


func gatherers_selected():
	if selected_units.empty(): return false
	for each in selected_units:
		if "can_gather" in each and each.can_gather: return true
	return false

func builders_selected():
	if selected_units.empty(): return false
	for each in selected_units:
		if "can_build" in each and each.can_build: return true
	return false
	


func kill():
	get_tree().reload_current_scene()


func credit_resources(resource_cost):
	var prev_resources = {}
	for resource in resources.keys():
		prev_resources[resource] = resources[resource]
	for resource in resource_cost.keys():

		resources[resource] += resource_cost[resource]
	emit_signal("resources_changed")


func debit_resources(resource_cost, cost_producer):
	var prev_resources = {}
	for resource in resources.keys():
		prev_resources[resource] = resources[resource]
	for resource in resource_cost.keys():
		assert(resource_cost[resource] <= resources[resource])

		resources[resource] -= resource_cost[resource]
	emit_signal("resources_changed")


func _on_Dispatcher_resource_right_clicked(resource):
	if selected_units.empty(): return
	if !gatherers_selected(): return
	var gatherer_units = []
	for each_unit in selected_units:
		if "can_gather" in each_unit and each_unit.can_gather:
			gatherer_units.append(each_unit)

	for gatherer in gatherer_units:
		gatherer.set_resource_target(resource)
		gatherer.set_task_gather()
		resource.gather_target_set(gatherer)

func select_all_onscreen(unit):
	selected_units = [unit]
	for each_unit in selected_units:
		each_unit.select()


func _on_Dispatcher_unit_left_clicked(unit):
	clear_selected()
	#doubleclick select all goes here
	if $DoubleClickTimer.is_stopped() == false and last_clicked == unit:
		select_all_onscreen(unit)
		emit_signal("unit_selected", selected_units[0])
		return
	last_clicked = unit
	$DoubleClickTimer.start()
	selected_units = [unit]
	unit.select()
	emit_signal("unit_selected", unit)


func _on_Dispatcher_resource_left_clicked(resource):
	clear_selected()

	last_clicked = resource
	selected_units = [resource]
	resource.select()
	emit_signal("resource_selected", resource)
