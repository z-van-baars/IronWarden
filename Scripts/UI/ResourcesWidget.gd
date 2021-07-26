extends Control

var player
var tools
var time_elapsed = 0

func _process(delta):
	$FPSLabel.text = "FPS [ " + str(Engine.get_frames_per_second()) + " ]"

func set_module_refs():
	player = get_tree().root.get_node("Main").local_player
	tools = get_tree().root.get_node("Main/Tools")

func _on_Dispatcher_player_resources_changed():
	update_labels()

func _on_Player_resources_changed():
	update_labels()


func _on_Dispatcher_unit_add_remove():
	update_labels()

func update_labels():
	var player_resources = player.get_resources()
	$Biomass/BGPanel/BiomassCount.text = tools.comma_sep(
		player_resources[ResourceTypes.RES.BIOMASS])
	$Alloy/BGPanel/AlloyCount.text = tools.comma_sep(
		player_resources[ResourceTypes.RES.ALLOY])
	$Warpstone/BGPanel/WarpstoneCount.text = tools.comma_sep(
		player_resources[ResourceTypes.RES.WARPSTONE])
	$Energy/BGPanel/EnergyCount.text = tools.comma_sep(
		player_resources[ResourceTypes.RES.ENERGY])
	$Command/BGPanel/CommandCount.text = tools.comma_sep(
		player_resources[ResourceTypes.RES.COMMAND])
	$Population/BGPanel/PopCount.text = tools.comma_sep(
		player.get_all_units().size()
	)
	

func start_clock():
	$GameClockPanel/Timer.start()
	format_time()
	update_clock()

func format_time():
	var string = str(time_elapsed)
	var mod = string.length() % 2
	var string_time = ""
	if time_elapsed < 3600:
		string_time += "00 : "
	if time_elapsed < 60:
		string_time += "00 : "
	if time_elapsed < 10:
		string_time += "0"

	for i in range(0, string.length()):
		if i != 0 && i % 2 == mod:
			string_time += " : "
		string_time += string[i]
	return string_time


func update_clock():
	$GameClockPanel/Label.text = format_time()


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_Timer_timeout():
	time_elapsed += 1
	update_clock()





