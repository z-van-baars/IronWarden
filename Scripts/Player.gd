extends Node2D

signal toggle_debug_menu
signal toggle_spawn_mode

var unit_scn = preload("res://Scenes/Unit.tscn")
var units
var mouse_in_menu = false

onready var dragging = false
onready var selected_units = []
onready var map_widget = get_tree().root.get_node("Main/UILayer/MapWidget")
onready var spawn_mode = get_tree().root.get_node("Main").spawn_mode
onready var last_clicked = null
onready var selection_box = get_tree().root.get_node("Main/SelectionBox")

onready var resources = {
	"Biomass": 100,
	"Alloys": 200,
	"Warpstone": 0,
	"Energy": 100,
	"Command": 0
}

func _ready():
	units = get_tree().root.get_node("Main/Units")
	self.connect("toggle_spawn_mode", map_widget, "_on_Player_spawn_mode_toggle")
	for each in selected_units:
		each.selected = true
	
func _input(event):
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
		if mouse_in_menu == true:
			
			return
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


func _on_Dispatcher_mouse_in_menu():
	mouse_in_menu = true


func _on_Dispatcher_mouse_out_of_menu():
	mouse_in_menu = false
