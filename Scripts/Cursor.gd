extends Node2D
onready var res = get_tree().root.get_node("Main/GameObjects/Resources")
enum CursorStyle {
	ARROW,
	BIOMASS_GATHER,
	ALLOY_GATHER,
	WARPSTONE_GATHER,
	ENERGY_GATHER,
	RESOURCE_DROPOFF,
	MAPSCROLL,
	ATTACK,
	RALLY_POINT
}


var classic = {
	CursorStyle.ARROW: load("res://Assets/Art/UI/Cursors/SciFi/cursor_generic.png"),
	CursorStyle.BIOMASS_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_tree.png"),
	CursorStyle.ALLOY_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.WARPSTONE_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.ENERGY_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.RESOURCE_DROPOFF: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.MAPSCROLL: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.ATTACK: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.RALLY_POINT: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png")
}
var scifi = {
	CursorStyle.ARROW: load("res://Assets/Art/UI/Cursors/SciFi/cursor_cracked_small.png"),
	CursorStyle.BIOMASS_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_tree.png"),
	CursorStyle.ALLOY_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.WARPSTONE_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.ENERGY_GATHER: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.RESOURCE_DROPOFF: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.MAPSCROLL: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.ATTACK: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png"),
	CursorStyle.RALLY_POINT: load("res://Assets/Art/UI/Cursors/ClassicSet/cursor_generic.png")
}
var metro_string = "res://Assets/Art/UI/Cursors/MetroSmall/"
var metro_sm = {
	CursorStyle.ARROW: load(metro_string + "arrow.png"),
	CursorStyle.BIOMASS_GATHER: load(metro_string + "biomass.png"),
	CursorStyle.ALLOY_GATHER: load(metro_string + "arrow.png"),
	CursorStyle.WARPSTONE_GATHER: load(metro_string + "arrow.png"),
	CursorStyle.ENERGY_GATHER: load(metro_string + "arrow.png"),
	CursorStyle.RESOURCE_DROPOFF: load(metro_string + "arrow.png"),
	CursorStyle.MAPSCROLL: load(metro_string + "arrow.png"),
	CursorStyle.ATTACK: load(metro_string + "arrow.png"),
	CursorStyle.RALLY_POINT: load(metro_string + "arrow.png")
}
var resource_cursors
func _ready():
	# Changes only the arrow shape of the cursor.
	# This is similar to changing it in the project settings.
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.ARROW])
	resource_cursors = {
		res.ResourceTypes.BIOMASS: CursorStyle.BIOMASS_GATHER,
		res.ResourceTypes.ALLOY: CursorStyle.BIOMASS_GATHER,
		res.ResourceTypes.WARPSTONE: CursorStyle.BIOMASS_GATHER,
		res.ResourceTypes.ENERGY: CursorStyle.BIOMASS_GATHER,
		res.ResourceTypes.BIOMASS: CursorStyle.BIOMASS_GATHER
	}


func _on_Dispatcher_reset_cursor():
	Input.set_custom_mouse_cursor(metro_sm[CursorStyle.ARROW])


func _on_Dispatcher_set_resource_cursor(resource):
	var cursor_style = resource_cursors[resource.r_type]
	Input.set_custom_mouse_cursor(metro_sm[cursor_style])
