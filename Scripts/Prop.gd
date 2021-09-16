extends "res://Scripts/GameObject.gd"
tool

enum PropTypes {
	Skelet,
	Corpse,
	Barrel
}

var prop_textures = {
	PropTypes.Skelet: [
		load("res://Assets/Art/Scenery/Props/Skeleton001.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton002.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton003.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton004.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton005.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton006.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton007.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton008.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton009.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton010.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton011.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton012.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton013.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton014.png"),
		load("res://Assets/Art/Scenery/Props/Skeleton015.png")],
	PropTypes.Corpse: [],
	PropTypes.Barrel: []
}

var props_list = [
	"Skeleton",
	"Corpse",
	"Barrel"
]

export(PropTypes) var prop_type setget SetPropType

func SetPropType(new_prop_type):
	prop_type = new_prop_type
	$Sprite.texture = Tools.r_choice(prop_textures[prop_type])
