extends Node2D
var tools
var units


var unit_spawns
var unit_greetings
var unit_confirmations
var unit_deaths




func _ready():
	tools = get_tree().root.get_node("Main/Tools")
	units = get_tree().root.get_node("Main//GameObjects/Units")

func _on_Dispatcher_unit_spawned(_unit):
	$MarineSpawn.play()

func _on_zoinks():
	$Zoinks.play()

func _on_flick1():
	$Flick1.play()

func _on_deny1():
	$Deny1.play()

func _on_deny2():
	$Deny2.play()

func _on_tick1():
	$Tick10.play()

func _on_spawn_sound():
	$SpawnChirp.play()

