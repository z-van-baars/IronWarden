extends Node2D
onready var nav_map = get_tree().root.get_node("Main/Nav2D")
onready var structure_map = get_node("StructureMap")
onready var structure_scn = preload("res://Scenes/Structure.tscn")


var command_post_stats = {
	"display name": "Command Post",
	"armor": 10,
	"maxhealth": 1000,
	"maxshields": 0,
	"attack": 0,
	"range": 0}

var structure_ids = {
	"Command Post": 0}

var statlines = {
	"Command Post": command_post_stats
}

var icons = {
	"Command Post": load("res://Assets/Art/command_post.png")
}


var build_options = {
	"Command Post": ["Engineer", "Lascannon", "Rhino"]}

var tech_options = {}
onready var tiles = []

func add_structure(structure_type, coordinates):
	var new_structure = structure_scn.instance()
	$All.add_child(new_structure)
	new_structure.position = $StructureMap.map_to_world(coordinates)
	nav_map.update_nav_tile(coordinates, -1)
	new_structure.load_stats(structure_type, coordinates)
	
	tiles[coordinates[1]][coordinates[0]] = structure_ids[structure_type]

