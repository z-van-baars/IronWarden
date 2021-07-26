extends Node2D

var main
var map_width
var map_height
var tools
var tile_map
var map_grid
var units
var st
var unscaled
var players
var local_player
var all_explored = false # cheat code
var all_visible = false # cheat code

onready var explored_tiles = {} # persistent record to minimize recalc over time
onready var newly_explored = {} # refreshed each update cycle to minimize redraw
onready var unexplored_tiles = {} # persistent record, inverse of explored dict
onready var visible_tiles = {} # persistent but continually updated each cycle


func _on_Dispatcher_all_explored():
	all_explored = !all_explored

func _on_Dispatcher_all_visible():
	all_visible = !all_visible

func set_module_refs():
	main = get_tree().root.get_node("Main")
	map_width = main.get_node("GameMap").width
	map_height = main.get_node("GameMap").height
	tools = main.get_node("Tools")
	tile_map = main.get_node("GameMap/TileMap")
	map_grid = main.get_node("GameMap/Grid")
	units = main.get_node("GameObjects/Units")
	st = main.get_node("GameObjects/Structures")
	local_player = main.local_player
	players = main.players
	for each_player in players.keys():
		explored_tiles[each_player] = {}
		newly_explored[each_player] = {}
		unexplored_tiles[each_player] = {}
		visible_tiles[each_player] = {}
	for _y in range(map_grid.tiles.size()):
		for _x in range(map_grid.tiles[0].size()):
			for each_player in players.keys():
				explored_tiles[each_player][Vector2(_x, _y)] = false
				unexplored_tiles[each_player][Vector2(_x, _y)] = true
				
	$FogTimer.start()

func create_fog_texture(tile_scale):
	var img = Image.new()
	img.create(
		map_width * tile_scale,
		map_height * tile_scale,
		false,
		Image.FORMAT_RGBA8)
	img.lock()
	return img

func reveal_tiles(img, tile_array, tile_scale, visible=false):
	var alpha_color = 0.25
	if visible: alpha_color = 0
	for tile in tile_array:
		for _y in range(tile_scale):
			for _x in range(tile_scale):
				img.set_pixel(
					tile.x * tile_scale + _x,
					tile.y * tile_scale + _y,
					Color(0, 0, 0, alpha_color))

		"""img.set_pixel(
			tile.x * tile_scale + 1,
			tile.y * tile_scale,
			Color(0, 0, 0, alpha_color))
		img.set_pixel(
			tile.x * tile_scale,
			tile.y * tile_scale + 1,
			Color(0, 0, 0, alpha_color))
		img.set_pixel(
			tile.x * tile_scale + 1,
			tile.y * tile_scale + 1,
			Color(0, 0, 0, alpha_color))"""

func redraw_fog():
	var tile_scale = 2
	var x = 0
	var y = 0
	var img = create_fog_texture(tile_scale)
	for row in map_grid.tiles:
		for tile in row:
			img.set_pixel(x, y, Color.black)
			img.set_pixel(x + 1, y, Color.black)
			img.set_pixel(x, y + 1, Color.black)
			img.set_pixel(x + 1, y + 1, Color.black)
			x += tile_scale
		x = 0
		y += tile_scale
	# reveal_tiles(img, get_all_explored(local_player.get_player_number()), tile_scale)
	# reveal_tiles(img, get_all_visible(local_player.get_player_number()), tile_scale, true)
	img.unlock()
	var itex = ImageTexture.new()
	itex.create_from_image(img)
	unscaled = itex
	$Unexplored.texture = itex
	$Unexplored.scale = Vector2(18.5, 18.5)
	$Unexplored.rotation_degrees = 45

func get_unscaled():
	return unscaled

func _on_FogTimer_timeout():
	update_fog_of_war()
	update_fog_tiles()

func _on_Grid_exploration_updated():
	update_fog_of_war()
	redraw_fog()

func initialize_fog_tilemap():
	for _y in range(map_grid.tiles.size()):
		for _x in range(map_grid.tiles[0].size()):
			$FogMap.set_cellv(Vector2(_x, _y), 0)
			

func update_fog_tiles():
	var player_number = local_player.get_player_number()
	for vis_tile in visible_tiles[player_number].keys():
		if visible_tiles[player_number][vis_tile] == true:
			$FogMap.set_cellv(vis_tile, -1)
	for ex_tile in explored_tiles[player_number].keys():
		if explored_tiles[player_number][ex_tile] == false:
			continue
		if visible_tiles[player_number].has(ex_tile):
			if visible_tiles[player_number][ex_tile] == false:
				$FogMap.set_cellv(ex_tile, 1)

func update_fog_of_war():

	var p_id = local_player.get_player_number()
	newly_explored[p_id] = {}
	var tile_visibility = smart_check_visible(p_id)
	
	for visible_tile in tile_visibility.keys():
		if tile_visibility[visible_tile] == false:
			visible_tiles[p_id][visible_tile] = false
			continue
		if explored_tiles[p_id][visible_tile] == false:
			newly_explored[visible_tile] = true
			explored_tiles[p_id][visible_tile] = true
		visible_tiles[p_id][visible_tile] = true

func mark_explored(player_number, visible_tiles):
	for tile in visible_tiles:
		map_grid.tiles[tile.y][tile.x].set_explored(player_number, true)

func get_all_explored(player_number):
	for _y in range(map_grid.tiles.size()):
		for _x in range(map_grid.tiles[0].size()):
			if map_grid.get_cell(Vector2(_x, _y)).get_explored(player_number):
				explored_tiles[player_number].append(Vector2(_x, _y))
				unexplored_tiles[player_number].erase(Vector2(_x, _y))

	return explored_tiles[player_number]


func smart_check_visible(player_number):
	var visible_tiles = {}
	var evaluated = {} # mark tiles if they are visible to avoid repeat checking
	var evaluations = 0 # super early exit
	for tile_row in map_grid.tiles:
		for tile in tile_row:
			visible_tiles[tile.get_pos()] = false
			evaluated[tile.get_pos()] = false
	for unit in players[player_number].get_all_units():
		var new_visible_tiles = get_visible_tiles(unit.position, unit.get_sight())
		for new_tile in new_visible_tiles:
			visible_tiles[new_tile] = true
			if evaluated[new_tile] == false:
				evaluations += 1
				evaluated[new_tile] = true
		if evaluations >= map_width * map_height:
			break
	return visible_tiles

func brute_check_all_visible(player_number):
	var all_visible = []
	for unit in units.get_children():
		if unit.get_player_number() != local_player.get_player_number():
			continue
		var new_tiles = get_visible_tiles(unit.position, unit.get_sight())
		for _new_tile in new_tiles:
			if tools.in_map(_new_tile) and not _new_tile in all_visible:
				all_visible.append(_new_tile)
	for structure in st.get_node("All").get_children():
		if structure.get_player_number() != local_player.get_player_number():
			continue
		var new_tiles = get_visible_tiles(structure.position, structure.get_sight())
		for _new_tile in new_tiles:
			if tools.in_map(_new_tile) and not _new_tile in all_visible:
				all_visible.append(_new_tile)
	return all_visible

func get_visible_tiles(location, radius):
	var tile_location = tile_map.world_to_map(location)
	return tools.get_nearby_tiles(
		tile_location, radius, true)




