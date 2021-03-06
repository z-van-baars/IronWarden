extends Node2D
var grid
var st
var construction_id
var construction_mode = false
var pos
var tile_map
var building_offset
var local_player


func set_module_refs():
	grid = get_tree().root.get_node("Main/GameMap/Grid")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	tile_map = get_tree().root.get_node("Main/GameMap/TileMap")
	local_player = get_tree().root.get_node("Main").local_player

func check_valid():
	return grid.construction_site_clear(pos, construction_id, local_player.get_player_number())

func _process(_delta):
	if not visible: return
	pos = tile_map.world_to_map(get_global_mouse_position())
	position = tile_map.map_to_world(pos)

	if check_valid(): set_valid()
	else:
		set_invalid()
	

func _unhandled_input(_event):
	if not visible: return

func clear():
	hide()

func set_selection_border(structure_size):
	var border_textures = {
		Vector2(1, 1): preload("res://Assets/Art/UI/selection_border_1x1.png"),
		Vector2(2, 2): preload("res://Assets/Art/UI/selection_border_2x2.png"),
		Vector2(3, 3): preload("res://Assets/Art/UI/selection_border_3x3.png"),
		Vector2(4, 4): preload("res://Assets/Art/UI/selection_border_4x4.png")
	}
	$SelectionBorder.texture = border_textures[structure_size]


func set_valid():
	$SelectionBorder.modulate = Color(1, 1, 1, 1)
	$Sprite.modulate = Color(0.55, 1.0, 0.55, 0.8)

func set_invalid():
	$SelectionBorder.modulate = Color(1.1, 0.25, 0.25, 1)
	$Sprite.modulate = Color(1.25, 0.75, 0.75, 0.8)

func setup(structure_type=null):
	if structure_type == null:
		$Sprite.visible = false
		clear()
		return
	$Sprite.visible = true
	show()
	construction_id = structure_type
	$Sprite.texture = st.icons[structure_type]
	building_offset = st.get_footprint_offset(structure_type)
	set_selection_border(Vector2(
		st.get_width(structure_type),
		st.get_height(structure_type)))

func _on_Dispatcher_construction_id_changed(structure_type):
	setup(structure_type)

func _on_Dispatcher_toggle_construction_mode():
	construction_mode = !construction_mode
	setup()
