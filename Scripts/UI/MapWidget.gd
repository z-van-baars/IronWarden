extends Control




func _on_Dispatcher_new_action_logged(action_string):
	$Panel/MapHeader.text = action_string
