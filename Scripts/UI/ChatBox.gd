extends Control
signal chat_message
signal cheatcode


func _ready():
	hide()
	
func close():
	get_tree().paused = false
	$InputCooldown.start()
	hide()


func Input(event):
	if event.is_action_pressed("esc"):
		close()


func _on_Dispatcher_open_chat_box():
	if not $InputCooldown.is_stopped(): return
	get_tree().paused = true
	$Panel/LineEdit.text = ""
	$Panel/LineEdit.grab_focus()
	show()

func _on_ChatButton_pressed():
	emit_signal("chat_message", $Panel/LineEdit.text)
	emit_signal("cheatcode", $Panel/LineEdit.text)
	close()

func _on_CancelButton_pressed():
	close()


func _on_LineEdit_text_entered(_new_text):
	_on_ChatButton_pressed()


func _on_CloseCooldown_timeout():
	pass
