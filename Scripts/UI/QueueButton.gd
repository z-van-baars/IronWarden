extends Control
signal clicked
var units
var res

var unit_type = null
var resource_cost = {}
var queue_pos
var active_production = false
var build_time

func setup(unit, queue_position):
	set_references()
	load_build_unit(unit)
	queue_pos = queue_position

func connect_signals(build_menu_node):
	self.connect(
		"clicked",
		build_menu_node,
		"_on_QueueButton_clicked")

func load_build_unit(build_unit):
	unit_type = build_unit
	$Button/Thumbnail.texture = units.thumbnail[unit_type]
	resource_cost = units.get_build_cost(unit_type)
	build_time = units.get_build_time(build_unit)
	hint_tooltip = "Build " + units.get_display_name(unit_type) + "\n"

func set_references():
	units = get_tree().root.get_node("Main/GameObjects/Units")
	res = get_tree().root.get_node("Main/GameObjects/Resources")

func _process(_delta):
	if not active_production:
		$ProgressBar.hide()
		return
	$ProgressBar.show()

func spacer_setup():
	# My god this is a hack and I hate it but it also works and is kinda elegant
	modulate = Color(0, 0, 0, 0)


func disable_button():
	modulate = Color(10.0, 0.8, 0.8)
	
func enable_button():
	modulate = Color(1, 1, 1)

func set_active_production():
	active_production = true

func set_inactive_production():
	active_production = false


	
func update_bar(time_left):
	$ProgressBar.value = 100 - (time_left / build_time) * 100


func _on_Button_pressed():
	print("My button has been pressed")
	emit_signal("clicked", queue_pos, resource_cost)


func _on_Button_button_down():
	print("My button has been pressed in")


func _on_Button_button_up():
	print("My button has been released")
