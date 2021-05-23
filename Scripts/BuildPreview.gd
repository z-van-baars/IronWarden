extends Node2D
var grid
var st
var construction_id
var pos
var tile_map
var building_offset


func set_module_refs():
	grid = get_tree().root.get_node("Main/GameMap/Grid")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	tile_map = get_tree().root.get_node("Main/GameMap/TileMap")

func check_valid():
	return grid.construction_site_clear(pos, construction_id)

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

func set_selection_box(structure_size):
	var box_textures = {
		Vector2(1, 1): preload("res://Assets/Art/UI/selection_box_1x1.png"),
		Vector2(2, 2): preload("res://Assets/Art/UI/selection_box_2x2.png"),
		Vector2(3, 3): preload("res://Assets/Art/UI/selection_box_3x3.png"),
		Vector2(4, 4): preload("res://Assets/Art/UI/selection_box_4x4.png")
	}
	$SelectionBox.texture = box_textures[structure_size]


func set_valid():
	$SelectionBox.modulate = Color(1, 1, 1, 1)
	$Sprite.modulate = Color(0.5, 0.9, 0.5, 1)

func set_invalid():
	$SelectionBox.modulate = Color(0.9, 0.5, 0.5, 1)
	$Sprite.modulate = Color(0.9, 0.5, 0.5, 1)

func setup(structure_type):
	construction_id = structure_type
	$Sprite.texture = st.icons[structure_type]
	building_offset = st.get_footprint_offset(structure_type)
	set_selection_box(Vector2(
		st.get_width(structure_type),
		st.get_height(structure_type)))

func _on_Dispatcher_construction_mode_entered(structure_type):
	setup(structure_type)
	show()


func _on_Dispatcher_construction_mode_exited():
	hide()
