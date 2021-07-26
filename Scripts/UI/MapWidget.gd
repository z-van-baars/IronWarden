extends Control
onready var main = get_tree().root.get_node("Main")
var map_width
var map_height
var tile_map
var map_grid
var units
var st
var fog
var camera
var scaling_factor
var player_score_labels = {}

func _on_Dispatcher_new_action_logged(action_string):
	$Panel/MapHeader.text = action_string

func set_module_refs():
	map_width = main.get_node("GameMap").width
	map_height = main.get_node("GameMap").height
	tile_map = main.get_node("GameMap/TileMap")
	map_grid = main.get_node("GameMap/Grid")
	units = main.get_node("GameObjects/Units")
	st = main.get_node("GameObjects/Structures")
	fog = main.get_node("GameObjects/Fog")
	camera = main.local_player.get_node("Camera2D")
	scaling_factor = Vector2(map_width, map_height)
	$MapTimer.start()
	create_score_labels()

func create_map_texture():
	var img = Image.new()
	img.create(
		map_width * 1,
		map_height * 1,
		false,
		Image.FORMAT_RGBA8)
	img.lock()
	return img

func create_unit_texture():
	var img = Image.new()
	img.create(
		1,
		1,
		false,
		Image.FORMAT_RGBA8)
	img.lock()
	return img

func clear_score_labels():
	for each in $PlayerScorePanel/VBoxContainer.get_children():
		each.queue_free()

func create_score_labels():
	clear_score_labels()
	for player in main.players.values():
		var score_label = Label.new()
		score_label.align = Label.ALIGN_RIGHT
		score_label.text = (
			player.get_name()
			)
		score_label.modulate = player.get_color() * 1.5
		player_score_labels[player.get_player_number()] = score_label
		$PlayerScorePanel/VBoxContainer.add_child(score_label)

func update_player_scores():
	for player in main.players.values():
		update_score_label(player.get_player_number())
		
func update_score_label(player_number):
	player_score_labels[player_number].text = (
			main.players[player_number].get_name()
		)

func get_tile_color(tile):
	if map_grid.get_cell(tile).get_base() == 0: return Color.limegreen

func draw_map():
	var map_img = create_map_texture()
	var unit_img = create_map_texture()

	var x = 0
	var y = 0
	for row in map_grid.tiles:
		for tile in row:
			map_img.set_pixel(x, y, get_tile_color(Vector2(x, y)))
			x += 1
		x = 0
		y += 1
	map_img.unlock()

	var maptex = ImageTexture.new()
	maptex.create_from_image(map_img)
	$Panel/MapLayers/Tiles.texture = maptex
	#$Panel/MapLayers/Tiles.rotation_degrees = 45
	var unit_marker = Vector2(2, 2)
	for unit in units.get_children():
		var marker_color
		if unit.get_player_number() != -1:
			marker_color = main.players[unit.get_player_number()].get_color()
		else:
			marker_color = Color.white
		unit_img.set_pixel(
			unit.get_tile_coords().x,
			unit.get_tile_coords().y,
			marker_color)
	for stru in st.get_node("All").get_children():
		unit_img.set_pixel(
			stru.get_tile_coords().x,
			stru.get_tile_coords().y,
			main.players[stru.get_player_number()].get_color())
	
	
	var unit_tex = ImageTexture.new()
	unit_tex.create_from_image(unit_img)
	
	$Panel/MapLayers/Units.texture = unit_tex
	#$Panel/MapLayers/Tiles.rotation_degrees = 45
	

	$Panel/MapLayers/Unexplored.texture = fog.get_unscaled()
	#$Panel/MapLayers/Unexplored.rotation_degrees = 45
	
	$Panel/ScreenBox/BoxPanel.rect_position = (camera.position / scaling_factor) * .66



func _on_MapTimer_timeout():
	# draw_map()
	update_player_scores()
