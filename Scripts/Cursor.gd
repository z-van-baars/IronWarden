extends Node2D
onready var res = get_tree().root.get_node("Main/GameObjects/Resources")
enum CursorStyle {
	ARROW,
	CROSSHAIR,
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


var metro_string = "res://Assets/Art/UI/Cursors/MetroSmall/"
var metro_sm = {
	CursorStyle.ARROW: load(metro_string + "arrow.png"),
	CursorStyle.CROSSHAIR: load(metro_string + "crosshair.png"),
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
var deposit_cursors
func set_module_refs():
	# Changes only the arrow shape of the cursor.
	# This is similar to changing it in the project settings.
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.ARROW])
	deposit_cursors = {
		DepositTypes.DEPOSIT.TREE: CursorStyle.TREE_GATHER,
		DepositTypes.DEPOSIT.ORE: CursorStyle.ORE_GATHER,
		DepositTypes.DEPOSIT.CRYSTAL: CursorStyle.CRYSTAL_GATHER,
		DepositTypes.DEPOSIT.VENT: CursorStyle.ENERGY_GATHER
	}


func _on_Dispatcher_reset_cursor():
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.ARROW])

func _on_Dispatcher_set_crosshair_cursor():
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.CROSSHAIR])

func _on_Dispatcher_set_build_cursor():
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.HAMMER])

func _on_Dispatcher_set_deposit_cursor(deposit):
	var cursor_style = deposit_cursors[deposit.get_id()]
	Input.set_custom_mouse_cursor(metro_sm[cursor_style])


func _on_Dispatcher_structure_placement_mode_entered(_structure_type):
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.HAMMER])


func _on_Dispatcher_structure_placement_mode_exited():
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.ARROW])







