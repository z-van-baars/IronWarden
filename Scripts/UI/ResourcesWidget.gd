extends Control

var player


func _ready():
	player = get_tree().root.get_node("Main/Player")
	update_labels()

func _on_Player_resources_changed():
	update_labels()

func update_labels():
	$Panel/Biomass/BGPanel/BiomassCount.text = str(player.resources["Biomass"])
	$Panel/Alloy/BGPanel/AlloyCount.text = str(player.resources["Alloy"])
	$Panel/Warpstone/BGPanel/WarpstoneCount.text = str(player.resources["Warpstone"])
	$Panel/Energy/BGPanel/EnergyCount.text = str(player.resources["Energy"])
	$Panel/Command/BGPanel/CommandCount.text = str(player.resources["Command"])
