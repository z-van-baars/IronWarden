extends Node2D

signal toggle_debug_menu
signal toggle_spawn_mode
signal escape_key_pressed
signal enter_key_pressed
signal resources_changed
signal unit_selected
signal resource_selected
signal selection_cleared
signal unit_move_to
signal construction_mode_right_clicked
signal new_construction

enum Players {
	PLAYER0,
	PLAYER1,
	PLAYER2,
	PLAYER3,
	PLAYER4,
	PLAYER5,
	PLAYER6,
	PLAYER7
	}



var _nickname = "" setget set_name, get_name
var _network_id = null
var _color = null
var _is_host = false setget set_host, get_host
var _is_local = false setget set_local, get_local
var _player_num

onready var unit_scn
onready var main
onready var dis
onready var grid
onready var res
onready var units
onready var st
onready var chatbox_cooldown
onready var _resources = {}
onready var _cps = [] # command posts
onready var tools
onready var _selected_units = []
onready var construction_mode = false
onready var construction_build_id = null

onready var selection_box = get_tree().root.get_node("Main/SelectionBox")

onready var _construction_options = []
onready var last_clicked = null

func _ready():
	set_process(false)

func setup():
	set_module_refs()
	connect_signals()
	set_process(true)

func set_module_refs():
	main = get_tree().root.get_node("Main")
	dis = get_tree().root.get_node("Main/Dispatcher")
	grid = main.get_node("GameMap/Grid")
	res = main.get_node("GameObjects/Resources")
	units = main.get_node("GameObjects/Units")
	st = main.get_node("GameObjects/Structures")
	chatbox_cooldown = main.get_node("UILayer/ChatBox/InputCooldown")
	unit_scn = preload("res://Scenes/Unit.tscn")
	tools = main.get_node("Tools")

func connect_signals():
	self.connect("toggle_debug_menu", dis, "_on_Player_toggle_debug_menu")
	self.connect("toggle_spawn_mode", dis, "_on_Player_toggle_spawn_menu")
	self.connect("escape_key_pressed", dis, "_on_Player_escape_key_pressed")
	self.connect("enter_key_pressed", dis, "_on_Player_enter_key_pressed")
	self.connect("resources_changed", dis, "_on_Player_resources_changed")
	self.connect("unit_selected", dis, "_on_Player_unit_selected")
	self.connect("resource_selected", dis, "_on_Player_resource_selected")
	self.connect("selection_cleared", dis, "_on_Player_selection_cleared")
	self.connect("unit_move_to", dis, "_on_Player_unit_move_to")
	self.connect("construction_mode_right_clicked", dis, "_on_Player_construction_mode_right_clicked")
	self.connect("new_construction", dis, "_on_Player_new_construction")

func on_start(tile_map):
	pass


func set_local(is_local):
	_is_local = is_local

func get_local():
	return _is_local

func set_host(is_host):
	_is_host = is_host
	if _is_host:
		set_player_number(Players.PLAYER0)

func set_network_id(net_id):
	_network_id = net_id

func get_network_id():
	return _network_id

func get_host():
	return _is_host

func set_name(new_name):
	_nickname = new_name

func get_name():
	return _nickname

func set_color(color):
	_color = color

func get_color():
	return _color

func get_player_number():
	return _player_num

func set_player_number(player_n):
	_player_num = player_n

func add_base(command_post):
	_cps.append(command_post)

func get_base():
	return _cps[0]

func delete_base(cp):
	_cps.erase(cp)

func import_profile(player_profile):
	set_name(player_profile.get_name())
	# do some hotkey and settings stuff after this
	# Idk maybe this should be moved out of the base player class

func set_initial_construction_options() -> void:
	_construction_options = [
		StructureTypes.STRUCT.COMMAND_POST,
		StructureTypes.STRUCT.BIOMASS_REACTOR,
		StructureTypes.STRUCT.ALLOY_FOUNDRY,
		StructureTypes.STRUCT.WARPSTONE_REFINERY,
		StructureTypes.STRUCT.ENERGY_CONDUIT,
		StructureTypes.STRUCT.BARRACKS,
		StructureTypes.STRUCT.TOWER
	]

func get_construction_options() -> Array: 
	return _construction_options

func set_initial_resources() -> void:
	_resources = {
		ResourceTypes.RES.BIOMASS: 0,
		ResourceTypes.RES.ALLOY: 0,
		ResourceTypes.RES.WARPSTONE: 0,
		ResourceTypes.RES.ENERGY: 0,
		ResourceTypes.RES.COMMAND: 0
	}

func get_resources() -> Dictionary:
	return _resources

func get_all_units():
	return get_tree().get_nodes_in_group("player_" + str(get_player_number()) + "_units")

func get_all_structures():
	return get_tree().get_nodes_in_group("player_" + str(get_player_number()) + "_structures")

func get_command_posts():
	var command_posts = []
	for each_structure in get_all_structures():
		if not each_structure.get_id() == StructureTypes.STRUCT.COMMAND_POST:
			continue
		command_posts.append(each_structure)
	return command_posts

func clear_selected() -> void:
	for each in _selected_units:
		each.deselect()
	_selected_units = []
	emit_signal("selection_cleared")

func get_selected() -> Array:
	return _selected_units

func _unhandled_input(_event):
	pass
func _on_Selection_Box_end(newly_selected):
	pass

func gatherers_selected() -> bool:
	if _selected_units.empty(): return false
	for each in _selected_units:
		if each.has_method("can_gather") and each.can_gather(): return true
	return false

func get_gatherers(selected : Array) -> Array:
	var gatherer_units = []
	for each_unit in selected:
		if each_unit.has_method("can_gather") and each_unit.can_gather():
			gatherer_units.append(each_unit)
	return gatherer_units

func constructors_selected() -> bool:
	if _selected_units.empty(): return false
	for each in _selected_units:
		if each.has_method("can_construct") and each.can_construct(): return true
	return false

func get_constructors(selected : Array) -> Array:
	var constructor_units = []
	for each_unit in selected:
		if each_unit.has_method("can_construct") and each_unit.can_construct():
			constructor_units.append(each_unit)
	return constructor_units

func check_resources(check_amounts : Dictionary) -> Dictionary:
	var checked_resources = {}
	for resource in check_amounts.keys():

		checked_resources[resource] = (
			_resources[resource] >= check_amounts[resource])
	return checked_resources

func credit_resources(credit_amounts) -> void:
	var prev_resources = {}
	for resource in _resources.keys():
		prev_resources[resource] = _resources[resource]

	for resource in credit_amounts.keys():

		_resources[resource] += credit_amounts[resource]
	emit_signal("resources_changed", self)


func debit_resources(debit_amounts) -> void:
	var prev_resources = {}
	for resource in _resources.keys():
		prev_resources[resource] = _resources[resource]


	for resource in debit_amounts.keys():
		assert(debit_amounts[resource] <= _resources[resource])

		_resources[resource] -= debit_amounts[resource]
	emit_signal("resources_changed", self)

func _on_Dispatcher_construction_mode_entered(structure_type : int) -> void:
	construction_mode = true
	construction_build_id = structure_type


func _on_Dispatcher_construction_mode_exited() -> void:
	construction_mode = false
	construction_build_id = null

func _on_Dispatcher_name_changed(new_name : String) -> void:
	set_name(new_name)

func _on_Dispatcher_unit_left_clicked(unit):
	pass

func _on_Dispatcher_unit_right_clicked(unit):
	pass

func _on_Dispatcher_deposit_left_clicked(deposit):
	pass

func _on_Dispatcher_deposit_right_clicked(deposit):
	pass




