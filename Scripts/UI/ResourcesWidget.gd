extends Control

var player
var res



func set_module_refs():
	player = get_tree().root.get_node("Main/Player")
	res = get_tree().root.get_node("Main/GameObjects/Resources")



func _on_Player_resources_changed():
	update_labels()

func update_labels():
	$Panel/Biomass/BGPanel/BiomassCount.text = str(
		player.resources[res.ResourceTypes.BIOMASS])
	$Panel/Alloy/BGPanel/AlloyCount.text = str(
		player.resources[res.ResourceTypes.ALLOY])
	$Panel/Warpstone/BGPanel/WarpstoneCount.text = str(
		player.resources[res.ResourceTypes.WARPSTONE])
	$Panel/Energy/BGPanel/EnergyCount.text = str(
		player.resources[res.ResourceTypes.ENERGY])
	$Panel/Command/BGPanel/CommandCount.text = str(
		player.resources[res.ResourceTypes.COMMAND])
