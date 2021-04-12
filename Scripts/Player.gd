extends Node2D

signal toggle_debug_menu
signal toggle_spawn_mode
signal resources_changed

var unit_scn = preload("res://Scenes/Unit.tscn")
var units

onready var dragging = false
onready var selected_units = []
onready var spawn_mode = get_tree().root.get_node("Main").spawn_mode
onready var last_clicked = null
onready var selection_box = get_tree().root.get_node("Main/SelectionBox")

onready var resources = {
	"Biomass": 200,
	"Alloy": 600,
	"Warpstone": 0,
	"Energy": 100,
	"Command": 0
}

func _ready():
	units = get_tree().root.get_node("Main/Units")
	for each in selected_units:
		each.selected = true
	
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
		for each in selected_units:
			each.deselect()
		selected_units = []
		if spawn_mode == true:
			var new_unit = unit_scn.instance()
			units.add_child(new_unit)
			new_unit.position = get_viewport().get_canvas_transform().xform_inv(get_viewport().get_mouse_position())
			new_unit.load_stats("Rhino")

		selection_box.start(get_viewport().get_canvas_transform().xform_inv(get_viewport().get_mouse_position()))
	if event.is_action_released("left_click"):
		selection_box.close()


	if event.is_action_pressed("right_click") and selected_units != []:
		var click_loc = get_viewport().get_canvas_transform().xform_inv(event.position)
		for each in selected_units:
			if each.can_path:
				each.path_to(click_loc)
			else:
				each.set_rally_point(click_loc)


func _on_Selection_Box_end(newly_selected):
	for each in selected_units:
		each.deselect()
	selected_units = []
	for each in newly_selected:
		selected_units.append(each)
		each.select()
	
func _on_Unit_left_click(unit):
	if $DoubleClickTimer.is_stopped() == false and last_clicked == unit:
		#doubleclick select all goes here
		pass
	last_clicked = unit
	$DoubleClickTimer.start()
	selected_units = [unit]
	unit.select()

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
		


func _on_resource_right_clicked(resource):
	if selected_units == []: return
	var gatherer_units = []
	for each_unit in selected_units:
		if each_unit.can_gather == true:
			gatherer_units.append(each_unit)
	if gatherer_units == []: return
	for gatherer in gatherer_units:
		gatherer.set_resource_target(resource)

func _on_unit_right_clicked(unit):
	pass
