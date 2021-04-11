extends Control
var mouse_in_menu

func _ready():
	mouse_in_menu = get_tree().root.get_node("Main/Player").mouse_in_menu
	$Panel/TestLabel.text = "Mouse in Menu: " + str(mouse_in_menu)


func update_label_text():
	$Panel/TestLabel.text = "Mouse in Menu: " + str(mouse_in_menu)


func _on_Dispatcher_mouse_in_menu():
	update_label_text()


func _on_Dispatcher_mouse_out_of_menu():
	update_label_text()
