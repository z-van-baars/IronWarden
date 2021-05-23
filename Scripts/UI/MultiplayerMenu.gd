extends Control
signal host_lobby
signal connect_to_lobby
signal player_name_changed

onready var main = get_tree().root.get_node("Main")
onready var network = main.get_node("Network")
onready var _nickname = ""

func quit_to_main():
	hide()
	$HostGamePopup.hide()

func _on_MultiplayerLobby_lobby_exited():
	_on_Multiplayer_pressed()

func _on_Multiplayer_pressed():
	show()
	$Panel/NickNameLabel.text = main.active_profile.get_name()
	$Panel.modulate = Color.white
	if main.active_profile.get_name() == "default":
		$Panel.modulate = Color(0.6, 0.6, 0.6)
		$NicknamePopup.show()

func reset_hostgame_popup():
	$HostGamePopup/Panel/LobbyNameField.text = ""
	$HostGamePopup/Panel/LobbyNameField.placeholder_text = "A Zac Table"
	$HostGamePopup/Panel/DirectIPField.text = ""
	$HostGamePopup/Panel/DirectIPField.placeholder_text = "127.0.0.1 (default localhost)"
	$HostGamePopup/Panel/PasswordField.text = ""
	$HostGamePopup/Panel/PasswordField.placeholder_text = "goats (default)"

func reset_joingame_popup():
	$JoinGamePopup/Panel/DirectIPField.text = ""
	$JoinGamePopup/Panel/DirectIPField.placeholder_text = "127.0.0.1 (default localhost)"
	$JoinGamePopup/Panel/PasswordField.text = ""
	$JoinGamePopup/Panel/PasswordField.placeholder_text = "goats (default)"

func _on_Cancel_pressed():
	$HostGamePopup.hide()
	reset_hostgame_popup()
	$JoinGamePopup.hide()
	reset_joingame_popup()

func _on_SetName_pressed():
	$NicknamePopup.hide()
	_nickname = str($NicknamePopup/LineEdit.text)
	$Panel/NickNameLabel.text = _nickname
	$Panel.modulate = Color.white
	emit_signal("player_name_changed", _nickname)

func _on_QuitToMain_pressed():
	quit_to_main()


func _on_HostGame_pressed():
	$Panel.modulate = Color(0.6, 0.6, 0.6)
	$HostGamePopup.show()

func _on_JoinGame_pressed():
	$Panel.modulate = Color(0.6, 0.6, 0.6)
	$JoinGamePopup.show()

func _on_CreateGame_pressed():
	emit_signal(
		"host_lobby",
		$HostGamePopup/Panel/LobbyNameField.text,
		$HostGamePopup/Panel/DirectIPField.text,
		$HostGamePopup/Panel/PasswordField.text)
	_on_Cancel_pressed()
	hide()

func _on_ConnectToGame_pressed():
	emit_signal(
		"connect_to_lobby",
		$JoinGamePopup/Panel/DirectIPField.text,
		$JoinGamePopup/Panel/PasswordField.text)
	_on_Cancel_pressed()
	hide()
