tool
extends "res://Scripts/UI/Techtree/Box.gd"

func _on_Box_item_rect_changed():
	update_data()
	update_graphics()


func _on_Box_script_changed():
	update_data()
	update_graphics()
