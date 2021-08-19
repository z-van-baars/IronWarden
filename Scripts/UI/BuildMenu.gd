extends Control
signal tick1
signal deny1
var active_structure = null
var build_button_scn = preload("res://Scenes/UI/BuildButton.tscn")
var tech_button_scn = preload("res://Scenes/UI/BuildButton.tscn")
var queue_button_scn = preload("res://Scenes/UI/QueueButton.tscn")
var last_queue_size = null
var player
var units


func new_game():
	player = get_tree().root.get_node("Main").local_player
	units = get_tree().root.get_node("Main/GameObjects/Units")
	clear_all()

func _process(_delta):
	set_cost_modulators()
	if not active_structure: return
	if active_structure.build_queue.size() != last_queue_size:
		clear_queue_buttons()
		if active_structure.build_queue.empty():
			$QueuePanel/ActiveQueueButton.hide()
			$QueuePanel/ActiveQueueButton.set_inactive_production()
			return
		update_queue_buttons()
	$QueuePanel/ActiveQueueButton.update_bar(active_structure.get_node("BuildTimer").time_left)

func clear_build_buttons():
	for child in $BuildPanel/ButtonGrid.get_children():
		child.queue_free()

func clear_queue_buttons():
	for child in $QueuePanel/BuildQueue.get_children():
		child.queue_free()

func clear_all():
	active_structure = null
	clear_build_buttons()
	clear_queue_buttons()
	$QueuePanel/ActiveQueueButton.hide()
	$QueuePanel/ActiveQueueButton.set_inactive_production()
	hide()

func update_queue_buttons():
	var qsize = active_structure.build_queue.size()
	last_queue_size = qsize
	var queue_index =  0
	$QueuePanel/ActiveQueueButton.setup(
		active_structure.build_queue[0],
		queue_index)
	$QueuePanel/ActiveQueueButton.show()
	$QueuePanel/ActiveQueueButton.set_active_production()
	
	if not qsize > 1: return

	for item in active_structure.build_queue.slice(1, qsize-1):
		queue_index += 1
		var new_button = queue_button_scn.instance()
		$QueuePanel/BuildQueue.add_child(new_button)
		new_button.setup(item, queue_index)
		new_button.connect_signals(self)

func set_cost_modulators():
	for build_button in $BuildPanel/ButtonGrid.get_children():
		build_button.enable_button()
		if check_cost(build_button.resource_cost) == false:
			build_button.disable_button()


func construct_buttons():
	for unit in active_structure.build_options:
		var new_button = build_button_scn.instance()
		$BuildPanel/ButtonGrid.add_child(new_button)
		new_button.setup(self, unit)

	for tech in active_structure.tech_options: pass

	if active_structure.build_queue.empty(): return
	update_queue_buttons()
	

func check_cost(resource_cost):
	for resource in resource_cost.keys():
		if player.get_resources()[resource] < resource_cost[resource]:
			return false
	return true

func _on_Build_Button_clicked(unit_type):
	var quantity = 1
	if player.get_shift():
		quantity = 5
	for _i in range(quantity):
		if check_cost(units.get_build_cost(unit_type)) == true and active_structure.build_queue.size() < 12:
			active_structure.add_to_queue(unit_type)
			player.debit_resources(units.get_build_cost(unit_type))
			# update_queue_buttons()
			emit_signal("tick1")
		else:
			emit_signal("deny1")
			continue


func _on_QueueButton_clicked(queue_index, resource_cost):
	player.credit_resources(resource_cost)
	active_structure.build_queue.remove(queue_index)
	active_structure.start_next_in_queue()
	emit_signal("tick1")


func _on_Dispatcher_open_build_menu(structure):
	active_structure = structure
	construct_buttons()
	show()

func _on_Dispatcher_selection_cleared():
	clear_all()

func _on_Dispatcher_unit_update():
	return
	construct_buttons()
	show()
