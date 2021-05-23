extends Node

onready var time = null setget set_time
onready var text = null setget set_text

func setup(input_time, input_text):
	set_time(input_time)
	set_text(input_text)

func set_time(new_time): time = new_time
func set_text(new_text): text = new_text
func get_time(): return time
func get_text(): return text
