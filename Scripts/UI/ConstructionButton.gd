extends Control
signal clicked
var st
var res

var structure_type = null
var resource_cost = {}

func setup(build_menu_node, structure):
	set_references()

	load_build_structure(structure)
	connect_signals(build_menu_node)

func spacer_setup():
	# My god this is a hack and I hate it but it also works and is kinda elegant
	modulate = Color(0, 0, 0, 0)

func set_references():
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	res = get_tree().root.get_node("Main/GameObjects/Resources")

func disable_button():
	modulate = Color(10.0, 0.8, 0.8)
	
func enable_button():
	modulate = Color(1, 1, 1)

func connect_signals(construction_menu_node):
	self.connect(
		"clicked",
		construction_menu_node,
		"_on_StructureButton_clicked")

func load_build_structure(build_structure):
	var _stats = st.statlines[build_structure]
	structure_type = build_structure
	resource_cost = st.get_cost(structure_type)
	hint_tooltip = "Build " + st.get_display_name(structure_type) + "\n"
	for resource in resource_cost:
		if resource_cost[resource] != 0:
			hint_tooltip += str(resource_cost[resource])
			hint_tooltip += " "
			hint_tooltip += res.string_from_id(resource)
			hint_tooltip += "\n"
	$Button.text = st.get_display_name(structure_type)[0].capitalize()
	$Button/Thumbnail.texture = st.thumbnail[structure_type]


func _on_Button_pressed():
	emit_signal("clicked", structure_type)
