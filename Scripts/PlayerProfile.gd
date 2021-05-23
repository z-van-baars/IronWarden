extends Resource
class_name PlayerProfile

export var _name = "" setget set_name, get_name
var hotkey_diff = {}
var settings_diff = {}

func set_name(new_name):
	_name = new_name

func get_name():
	return _name
