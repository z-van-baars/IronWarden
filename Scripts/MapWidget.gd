extends Control

var priority_message = null
var priorty_subheader = null
var default_message = "Selected Units"
var default_subheader = null

func _ready():
	pass


func _process(delta):
	if priority_message == null:
		$Panel/WidgetHeader.text = default_message
	else:
		$Panel/WidgetHeader.text = priority_message
	$Panel/SubHeader.text = str(
		get_tree().root.get_node("Main/Player").selected_units)


func _on_Player_spawn_mode_toggle():
	$Panel/WidgetHeader.text = "Spawn Mode Enabled"


func _on_Header_priority_message(message_str, sub_header_message_str):
	$Panel/SubHeader.text = str(
		get_tree().root.get_node("Main/Player").selected_units)
