extends Control
signal start_multiplayer_game
signal lobby_exited

var lobby_player_card = preload("res://Scenes/UI/LobbyPlayer.tscn")
var human_player_scn = preload("res://Scenes/HumanPlayer.tscn")

onready var main = get_tree().root.get_node("Main")
onready var network = main.get_node("Network")

var lobby_name
var player_slots = []
var settings = {}
var local_player



	# Call function to update lobby UI here
func _on_MultiplayerMenu_host_lobby(_lobby_name, _connection_ip, _lobby_password):
	show()
	lobby_name = _lobby_name
	$Panel/Panel/LobbyNameHeader.text = lobby_name
	network.create_server(_connection_ip)
	player_slots.append(network.get_connected_players()[1])
	$Panel/MenuButtons/StartGame.show()
	update_roster_display()

func clear_roster_display():
	for each in $Panel/PlayerRoster/VBoxContainer.get_children():
		each.queue_free()

func update_roster_display():
	clear_roster_display()
	for player_slot in player_slots:
		var new_player_card = lobby_player_card.instance()
		new_player_card.get_node("NamePanel/Label").text = player_slot.name
		new_player_card.get_node("NamePanel/Label").modulate = player_slot.color
		if player_slot.host:
			new_player_card.get_node("NamePanel/Label").text += " [H]"
		$Panel/PlayerRoster/VBoxContainer.add_child(new_player_card)

func _on_StartGame_pressed():
	for id in network.get_connected_players():
		rpc_id(id, "set_self_local", id)
	rpc("launch_multiplayer_game")

sync func launch_multiplayer_game():
	hide()
	emit_signal("start_multiplayer_game", lobby_name, network.get_connected_players(), settings)

sync func set_self_local(id):
	network.get_connected_players()[id].local = true


func _on_MultiplayerMenu_connect_to_lobby(connection_ip, connection_password):
	network.connect_to_server(connection_ip, connection_password)
	show()

func _on_Network_roster_changed():
	player_slots = []
	for _n in range(network.get_connected_players().keys().size()):
		player_slots.append(0)
	for _player_data in network.get_connected_players().values():
		player_slots[_player_data.number] = _player_data
	update_roster_display()


func _on_LeaveLobby_pressed():
	hide()
	player_slots = []
	clear_roster_display()
	network.disconnect_from_lobby()
	emit_signal("lobby_exited")
