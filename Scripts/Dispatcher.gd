extends Node
var inbound = []
var archived = []
signal mouse_in_menu
signal mouse_out_of_menu
signal unit_hovered
signal unit_unhovered
signal open_build_menu
signal unit_selected
signal unit_deselected
signal resource_right_clicked

func add_event(event, event_args):
	inbound.append(event)

func _process(delta):
	while inbound != []:
		var active_event = inbound[0]
		archived.append(active_event)
		pass

func _on_Unit_hovered(unit):
	emit_signal("unit_hovered", unit)

func _on_Unit_unhovered():
	emit_signal("unit_unhovered")

func _on_Unit_selected(unit):
	emit_signal("unit_selected", unit)

func _on_Production_Structure_selected(unit, build_options=null, tech_options=null):
	if build_options != null or tech_options != null:
		emit_signal("open_build_menu", unit)

func _on_Unit_deselected():
	emit_signal("unit_deselected")

func _on_Resource_right_clicked(resource):
	emit_signal("resource_right_clicked", resource)
