extends Node2D
signal connected_to_server
signal network_peer_disconnected
signal roster_changed


const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 4

var color_by_number = {
	0: Color.blue,
	1: Color.red,
	2: Color.yellow,
	3: Color.limegreen
	}

var main
var _connected_players = {}
var _player_data = {
	name = "",
	number = null,
	color = Color.blue,
	faction = null,
	net_id = null,
	host = false,
	local = false
}

func _ready():
	main = get_tree().root.get_node("Main")
	get_tree().connect('network_peer_disconnected', self, '_player_disconnected')
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(id):
	print("Player [" + str(id) + "] connected to server")

func _connected_fail():
	print("server connection failed")

func _server_disconnected():
	print("server disconnected")
	print(_player_data.name + ", " + str(_player_data.net_id))
	emit_signal("roster_changed")

func _player_disconnected(id):
	print("Player [" + str(id) + "]  disconnected from server")
	_connected_players.erase(id)
	emit_signal("roster_changed")

func disconnect_from_lobby():
	get_tree().network_peer = null

func get_connected_players():
	return _connected_players

func clear_roster():
	_connected_players = {}


func create_server(connection_ip=DEFAULT_IP, _connection_password="goats"):
	clear_roster()
	_player_data.name = main.active_profile.get_name()
	_player_data.number = 0
	_player_data.color = Color.blue
	_player_data.faction = "imperium"
	_connected_players[1] = _player_data


	if _connection_password.ends_with("(default)"):
		_connection_password = "goats"
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	_player_data.net_id = get_tree().get_network_unique_id()

func connect_to_server(connection_ip=DEFAULT_IP, _connection_password="goats"):
	clear_roster()
	_player_data.name = main.active_profile.get_name()

	get_tree().connect('connected_to_server', self, '_on_connected_to_server')
	if _connection_password.ends_with("(default)"):
		_connection_password = "goats"
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	
	get_tree().set_network_peer(peer)
	_player_data.net_id = get_tree().get_network_unique_id()

remote func _get_lobby_credentials(id):
	rpc_id(id, "_receive_lobby_credentials", _connected_players)

func _on_connected_to_server():
	_connected_players[_player_data.net_id] = _player_data
	print(_connected_players)
	print("connected to server")

	rpc_id(1, '_get_lobby_credentials', _player_data.net_id)

remote func _receive_lobby_credentials(connected_players):
	print("receiving credentials....")
	print(_connected_players)
	for net_id in connected_players.keys():
		_connected_players[net_id] = connected_players[net_id]
	_player_data.number = connected_players.keys().size()
	_player_data.color = color_by_number[_player_data.number]
	rpc('_send_player_data', _player_data.net_id, _player_data)
	emit_signal("roster_changed")


remote func _send_player_data(id, player_data):
	# All rpc calls run this
	_connected_players[id] = player_data
	print(_connected_players)
	emit_signal("roster_changed")
	# Only run this if we're the host
	if get_tree().is_network_server():
		for peer_id in _connected_players:
			rpc_id(id, '_send_player_data', peer_id, _connected_players[peer_id])
			print("sending data..." + str(peer_id))


