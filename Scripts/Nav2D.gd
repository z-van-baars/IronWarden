extends Navigation2D

onready var grid
onready var width
onready var height
onready var st
onready var res

func set_module_refs():
	grid = get_tree().root.get_node("Main/GameMap/Grid")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	res = get_tree().root.get_node("Main/GameObjects/Resources")

func import_map_data(game_map):
	width = game_map.width
	height = game_map.height
	set_nav_tiles()

func set_nav_tiles():
	$NavMap.clear()
	for y in range(height):
		for x in range(width):
			$NavMap.set_cellv(Vector2(x, y), -1)
	for each in res.get_node("Deposits").get_children():
		$NavMap.set_cellv(each.pos, 1)
	for each in st.get_structures():
		for _tile in each.get_footprint():
			$NavMap.set_cellv(_tile.x, _tile.y, 1)

func add_tile_outline(tile_coords):
	var world_coords = $NavMap.map_to_world(tile_coords)
	# print(tile_coords)
	# print(world_coords)
	var new_outline = PoolVector2Array([
		Vector2(world_coords.x - 48, world_coords.y + 26),
		Vector2(world_coords.x, world_coords.y),
		Vector2(world_coords.x + 48, world_coords.y + 26),
		Vector2(world_coords.x, world_coords.y + 51)])
	$NavPoly.navpoly.add_outline(new_outline)
	#print($NavPoly.navpoly.get_polygon_count())
	
	$NavPoly.navpoly.make_polygons_from_outlines()
	#print($NavPoly.navpoly.get_outline(0))
	#print($NavPoly.navpoly.get_outline(1))
	# print($NavPoly.navpoly.get_polygon_count())

func add_collision_outline(collidable_node):
	var new_polygon = PoolVector2Array()
	var polygon = $NavPoly.get_navigation_polygon()
	print($NavPoly.navpoly.get_polygon_count())
	var polygon_transform = collidable_node.get_node("NavPolygon2D").get_global_transform()
	var polygon_bp = collidable_node.get_node("NavPolygon2D").get_polygon()
	for vertex in polygon_bp:
		new_polygon.append(polygon_transform.xform(vertex))
	polygon.add_outline(new_polygon)
	polygon.make_polygons_from_outlines()
	$NavPoly.set_navigation_polygon(polygon)
	$NavPoly.enabled = false
	$NavPoly.enabled = true
	print($NavPoly.navpoly.get_polygon_count())
	

func update_nav_tile(tile_location, tile_block_id):
	$NavMap.set_cellv(
		tile_location, tile_block_id)
