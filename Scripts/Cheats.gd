extends Node
signal zoinks
var cheats = []
var command_center = null
var player
var res

func set_module_refs():
	res = get_tree().root.get_node("Main/GameObjects/Resources")
	player = get_tree().root.get_node("Main").local_player

	command_center = get_tree().root.get_node("Main/GameObjects/Structures/All").get_children()[0]

func _on_ChatBox_cheatcode(cheat_string):
	match cheat_string:
		"spess mehren":
			command_center.spawn_unit(1)
			emit_signal("zoinks")
		"metal bawkses":
			player.credit_resources({res.ResourceTypes.ALLOY: 1000})
			emit_signal("zoinks")
		"steakums":
			player.credit_resources({res.ResourceTypes.BIOMASS: 1000})
			emit_signal("zoinks")
		"history's mysteries":
			player.credit_resources({res.ResourceTypes.WARPSTONE: 1000})
			emit_signal("zoinks")
		"unlimited powah":
			player.credit_resources({res.ResourceTypes.ENERGY: 1000})
			emit_signal("zoinks")
		"biomass":
			player.credit_resources({res.ResourceTypes.COMMAND: 100})
			emit_signal("zoinks")
		"more dakka":
			for _c in range(10):
				command_center.spawn_unit(2)
			emit_signal("zoinks")
