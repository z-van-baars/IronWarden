extends Node
var inbound = []
var archived = []
var build_menu
signal mouse_in_menu
signal mouse_out_of_menu

func _ready():
	build_menu = get_tree().root.get_node("Main/UILayer/BuildMenu")

func add_event(event, event_args):
	inbound.append(event)

func _process(delta):
	while inbound != []:
		var active_event = inbound[0]
		archived.append(active_event)
		pass

func _on_Object_hovered(args):
	pass

func _on_Build_Structure_selected(structure):
	build_menu._on_Structure_selected(structure)

func _on_Build_Structure_deselected():
	build_menu._on_Structure_deselected()


func _on_Menu_mouse_entered(menu):
	emit_signal("mouse_in_menu")


func _on_Menu_mouse_exited():
	emit_signal("mouse_out_of_menu")
