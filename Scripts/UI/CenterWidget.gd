extends Control

var selected_unit = null

func _ready():
	clear_all()

func clear_all():
	$Panel/UnitHeader.text = ""
	$Panel/HealthBar.hide()
	$Panel/HealthLabel.text = ""
	
	$Panel/StatBGPanel.hide()

func _on_Unit_selected(unit):
	selected_unit = unit
	$Panel/UnitHeader.text = unit.display_name
	$Panel/HealthBar.value = (unit.health / unit.maxhealth) * 100
	$Panel/HealthBar.show()
	$Panel/HealthLabel.text = str(unit.health) + " / " + str(unit.maxhealth)
	
	$Panel/StatBGPanel.show()
	$Panel/StatBGPanel/StatLabels/Armor.text = str(unit.armor)
	$Panel/StatBGPanel/StatLabels/Attack.text = str(unit.attack)
	$Panel/StatBGPanel/StatLabels/Range.text = str(unit.attack_range)

func _on_Unit_deselected():
	selected_unit = null
	clear_all()
