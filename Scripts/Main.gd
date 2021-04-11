extends Node

var tools
var units

#debug junk
var draw_paths = true
var draw_nav_polys = true
var spawn_mode = false

func _ready():
	tools = $Tools
	units = $Units

	$GameMap.map_gen()
	$Nav2D.import_map_data($GameMap)


	# var random_start = tools.get_random_coordinates($GameMap.tiles, 1)[0]
	var random_start = Vector2(
		int($GameMap.width / 2) + tools.rng.randi_range(-5, 5),
		int($GameMap.height / 2) + tools.rng.randi_range(-5, 5))
	
	$Structures.add_structure("Command Post", random_start)
	var center_point = $Structures/All.get_children()[0].get_center()
	for _x in range(3):
		var random_loc = tools.circ_random(center_point, 150)
		$Units.add_unit("Engineer", center_point + random_loc)
	$Player/Camera2D.center_on_tile(random_start)



