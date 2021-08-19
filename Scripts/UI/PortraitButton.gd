extends Control
signal clicked
var units
var res

var _unit = null
var unit_type = null

func setup(unit):
	set_references()
	load_unit(unit)

func connect_signals(menu_node, method_string="_on_PortraitButton_clicked"):
	self.connect(
		"clicked",
		menu_node,
		"_on_PortraitButton_clicked")

func load_unit(unit):
	_unit = unit
	unit_type = unit.get_id()
	$Button/Thumbnail.texture = unit.get_thumbnail()
	hint_tooltip = unit.get_display_name()

func set_references():
	units = get_tree().root.get_node("Main/GameObjects/Units")

func spacer_setup():
	# My god this is a hack and I hate it but it also works and is kinda elegant
	modulate = Color(0, 0, 0, 0)

func disable_button():
	modulate = Color(10.0, 0.8, 0.8)
	
func enable_button():
	modulate = Color(1, 1, 1)


func _on_Button_pressed():
	print("cheese")
	emit_signal("clicked", _unit)


func _on_Button_mouse_entered():
	pass
