extends Node2D

var map_width
var map_height
var tile_map
var map_grid
var units
var st
var unscaled

func set_module_refs():
	map_width = get_tree().root.get_node("Main/GameMap").width
	map_height = get_tree().root.get_node("Main/GameMap").height
	tile_map = get_tree().root.get_node("Main/GameMap/TileMap")
	map_grid = get_tree().root.get_node("Main/GameMap/Grid")
	units = get_tree().root.get_node("Main/GameObjects/Units")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	$FogTimer.start()

func create_fog_texture():
	var img = Image.new()
	img.create(
		map_width * 2,
		map_height * 2,
		false,
		Image.FORMAT_RGBA8)
	img.lock()
	return img

func reveal_tiles(img, tile_array, visible=false):
	var alpha_color = 0.25
	if visible: alpha_color = 0
	for tile in tile_array:
		img.set_pixel(
			tile.x * 2,
			tile.y * 2,
			Color(0, 0, 0, alpha_color))
		img.set_pixel(
			tile.x * 2 + 1,
			tile.y * 2,
			Color(0, 0, 0, alpha_color))
		img.set_pixel(
			tile.x * 2,
			tile.y * 2 + 1,
			Color(0, 0, 0, alpha_color))
		img.set_pixel(
			tile.x * 2 + 1,
			tile.y * 2 + 1,
			Color(0, 0, 0, alpha_color))

func draw_fog():
	var x = 0
	var y = 0
	var img = create_fog_texture()
	for row in map_grid.tiles:
		for tile in row:
			img.set_pixel(x, y, Color.black)
			img.set_pixel(x + 1, y, Color.black)
			img.set_pixel(x, y + 1, Color.black)
			img.set_pixel(x + 1, y + 1, Color.black)
			x += 2
		x = 0
		y += 2
	reveal_tiles(img, map_grid.get_explored())
	reveal_tiles(img, map_grid.get_visible(), true)
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
	map_grid.update_fog_of_war()
	draw_fog()


func _on_DrawFogTimer_timeout():
	draw_fog()
