extends Control
signal box_clicked
var click_loc

func _ready():
	pass
	#pause_all()

func _on_CloseButton_pressed():
	hide()

func _on_Dispatcher_open_tech_tree():
	$InfoPanel.hide()
	show()
	#unpause_all()
	
func _input(event):
	if event.is_action_pressed("left_click"):
		# get_viewport().get_canvas_transform().xform_inv(get_viewport().get_mouse_position())
		click_loc = get_viewport().get_mouse_position()
		
	if event.is_action_pressed("esc"):
		if $InfoPanel.visible:
			$InfoPanel.hide()
			return
		hide()
			
func pause_all():
	for each in explore_tree():
		each.set_process(false)

func unpause_all():
	for each in explore_tree():
		each.set_process(true)

func explore_tree() -> Array:
	var explored = false
	var children = [get_node("Panel/Command Post")]
	children += get_node("Panel/Command Post").get_children()
	var new_subchildren = []
	while not explored:
		print("not explored")
		explored = true
		for child_node in children:
			if not child_node.get_children().empty():
				explored = false
				for new_subchild in child_node.get_children():
					new_subchildren.append(new_subchild)
		children += new_subchildren
	
	return children

func _on_Box_clicked(display_name, cost_string, stats_string):
	emit_signal("box_clicked", click_loc, display_name, cost_string, stats_string)


func _on_Panel_gui_input(event):
	if event.is_action_pressed("left_click"):
		if $InfoPanel.visible:
			$InfoPanel.hide()
			return
