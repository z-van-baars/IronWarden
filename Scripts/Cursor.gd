extends Node2D
onready var res = get_tree().root.get_node("Main/GameObjects/Resources")
enum CursorStyle {
	ARROW,
	HAMMER,
	TREE_GATHER,
	ORE_GATHER,
	CRYSTAL_GATHER,
	CHICKEN_GATHER,
	ENERGY_GATHER,
	RESOURCE_DROPOFF,
	MAPSCROLL,
	ATTACK,
	RALLY_POINT
}


var classic = {
	CursorStyle.ARROW: load("res://Assets/Art/UI/Cursors/SciFi/cursor_generic.png"),
	CursorStyle.HAMMER: load("res://Assets/Art/UI/Cursors/SciFi/cursor_generic.png"),
	CursorStyle.TREE_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_tree.png"),
	CursorStyle.ORE_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.CRYSTAL_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.ENERGY_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.CRYSTAL_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.RESOURCE_DROPOFF: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.MAPSCROLL: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.ATTACK: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.RALLY_POINT: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png")
}
var scifi = {
	CursorStyle.ARROW: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png"),
	CursorStyle.HAMMER: load("res://Assets/Art/UI/Cursors/SciFi/cursor_generic.png"),
	CursorStyle.TREE_GATHER: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png"),
	CursorStyle.ORE_GATHER: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png"),
	CursorStyle.CRYSTAL_GATHER: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png"),
	CursorStyle.ENERGY_GATHER: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png"),
	CursorStyle.CRYSTAL_GATHER: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png"),
	CursorStyle.RESOURCE_DROPOFF: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png"),
	CursorStyle.MAPSCROLL: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png"),
	CursorStyle.ATTACK: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png"),
	CursorStyle.RALLY_POINT: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png")
}
var metro_string = "res://Assets/Art/UI/Cursors/MetroSmall/"
var metro_sm = {
	CursorStyle.ARROW: load(metro_string + "arrow.png"),
	CursorStyle.HAMMER: load(metro_string + "hammer.png"),
	CursorStyle.TREE_GATHER: load(metro_string + "axe.png"),
	CursorStyle.ORE_GATHER: load(metro_string + "pick.png"),
	CursorStyle.CRYSTAL_GATHER: load(metro_string + "pick.png"),
	CursorStyle.CHICKEN_GATHER: load(metro_string + "knife.png"),
	CursorStyle.ENERGY_GATHER: load(metro_string + "arrow.png"),
	CursorStyle.RESOURCE_DROPOFF: load(metro_string + "arrow.png"),
	CursorStyle.MAPSCROLL: load(metro_string + "arrow.png"),
	CursorStyle.ATTACK: load(metro_string + "arrow.png"),
	CursorStyle.RALLY_POINT: load(metro_string + "arrow.png")
}
var resource_cursors
func set_module_refs():
	# Changes only the arrow shape of the cursor.
	# This is similar to changing it in the project settings.
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.ARROW])
	resource_cursors = {
		DepositTypes.DEPOSIT.TREE: CursorStyle.TREE_GATHER,
		DepositTypes.DEPOSIT.ORE: CursorStyle.ORE_GATHER,
		DepositTypes.DEPOSIT.CRYSTAL: CursorStyle.CRYSTAL_GATHER,
		DepositTypes.DEPOSIT.VENT: CursorStyle.ENERGY_GATHER
	}


func _on_Dispatcher_reset_cursor():
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.ARROW])


func _on_Dispatcher_set_resource_cursor(resource):
	var cursor_style = resource_cursors[resource.d_type]
	Input.set_custom_mouse_cursor(metro_sm[cursor_style])


func _on_Dispatcher_structure_placement_mode_entered(_structure_type):
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.HAMMER])


func _on_Dispatcher_structure_placement_mode_exited():
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.ARROW])
