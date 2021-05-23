extends Control
signal open_tech_tree

export var audio_bus_name := "Master"

onready var _bus := AudioServer.get_bus_index(audio_bus_name)



func _ready() -> void:
	AudioServer.set_bus_volume_db(_bus, linear2db(0.25))
	update_buttons()

func update_buttons():
	$Panel/HSlider.value = db2linear(AudioServer.get_bus_volume_db(_bus))
	$Panel/VolumeSliderLabel.text = "Game Master Volume - " + str(db2linear(AudioServer.get_bus_volume_db(_bus)))

func _on_Player_toggle_options_menu():
	visible = !visible
	get_tree().paused = !get_tree().paused
	update_buttons()

func _on_HSlider_changed():
	get_tree().paused = false
	AudioServer.set_bus_volume_db(_bus, linear2db($Panel/HSlider.value))
	get_tree().paused = true
	update_buttons()

func _on_CloseButton_pressed():
	_on_Player_toggle_options_menu()

func _input(event):
	if event.is_action_pressed("esc"):
		_on_Player_toggle_options_menu()

func _on_QuitGame_pressed():
	get_tree().quit()


func _on_HSlider_value_changed(value):
	# get_tree().paused = false
	AudioServer.set_bus_volume_db(_bus, linear2db(value))
	# get_tree().paused = true
	update_buttons()


func _on_VolumeSliderLabel_pressed():
	$Panel/HSlider.value = 0.75
	_on_HSlider_value_changed(0.75)


func _on_ResumeGame_pressed():
	_on_Player_toggle_options_menu()


func _on_OpenTechTree_pressed():
	emit_signal("open_tech_tree")
