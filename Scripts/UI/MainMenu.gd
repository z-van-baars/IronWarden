extends Control
signal tick1
signal flick1


func _ready():
	OS.set_window_maximized(true)

	get_tree().paused = true
	hide_panels()
	show()

func _on_NewGame_pressed():
	emit_signal("tick1")
	get_tree().paused = false
	hide()

func _on_Quit_pressed():
	emit_signal("tick1")
	get_tree().quit()

func hide_panels():
	$Panel/MenuButtons/NewGame/Panel.hide()
	$Panel/MenuButtons/CustomGame/Panel.hide()
	$Panel/MenuButtons/Multiplayer/Panel.hide()
	$Panel/MenuButtons/Quit/Panel.hide()



func _on_NewGame_mouse_entered():
	$Panel/MenuButtons/NewGame/Panel.show()
	emit_signal("flick1")


func _on_NewGame_mouse_exited():
	hide_panels()

func _on_CustomGame_mouse_entered():
	$Panel/MenuButtons/CustomGame/Panel.show()
	emit_signal("flick1")


func _on_CustomGame_mouse_exited():
	hide_panels()

func _on_Multiplayer_mouse_entered():
	$Panel/MenuButtons/Multiplayer/Panel.show()
	emit_signal("flick1")



func _on_Multiplayer_mouse_exited():
	hide_panels()

func _on_Quit_mouse_entered():
	$Panel/MenuButtons/Quit/Panel.show()
	emit_signal("flick1")

func _on_Quit_mouse_exited():
	hide_panels()


func _on_MultiplayerLobby_start_multiplayer_game(lobby_name, players, settings):
	get_tree().paused = false
	hide()
