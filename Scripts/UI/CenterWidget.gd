extends Control

onready var su = null
onready var res = get_tree().root.get_node("Main/GameObjects/Resources")

func _ready():
	clear_all()

func _process(delta):
	update_display()

func clear_all():
	$Panel/UnitHeader.hide()
	$Panel/HealthBar.hide()
	$Panel/HealthLabel.hide()
	$Panel/StatBGPanel.hide()
	$Panel/ResourceSprite.hide()
	$Panel/ResourceLabel.hide()

func _on_Unit_selected(unit):
	clear_all()
	su = unit
	update_display()

func update_display():
	if not su: return

	$Panel/UnitHeader.show()
	$Panel/UnitHeader.text = su.get_display_name()

	$Panel/HealthBar.show()
	$Panel/HealthBar.max_value = su.get_maxhealth()
	$Panel/HealthBar.value = su.get_health()
	
	$Panel/HealthLabel.show()
	$Panel/HealthLabel.text = str(su.get_health()) + " / " + str(su.get_maxhealth())

	if "get_armor" in su:
		$Panel/StatBGPanel.show()
		$Panel/StatBGPanel/StatLabels/Armor.text = str(su.get_armor())
		$Panel/StatBGPanel/StatLabels/Attack.text = str(su.get_attack())
		$Panel/StatBGPanel/StatLabels/Range.text = str(su.get_range())
	else:
		$Panel/StatBGPanel.hide()
	$Panel/ResourceHint.hint_tooltip = ""
	if "can_gather" in su and su.can_gather:
		for r_type in su.carrying.keys():
			if su.carrying[r_type] > 0:
				$Panel/ResourceSprite.show()
				$Panel/ResourceSprite.texture = res.icons[r_type]
				$Panel/ResourceLabel.show()
				$Panel/ResourceLabel.text = str(su.get_carried(r_type))
				$Panel/ResourceHint.hint_tooltip = res.string_from_id(r_type)
				return

	if "remaining" in su:
		for r_type in su.remaining.keys():
			if su.remaining[r_type] > 0:
				$Panel/ResourceSprite.show()
				$Panel/ResourceSprite.texture = res.icons[r_type]
				$Panel/ResourceLabel.show()
				$Panel/ResourceLabel.text = str(su.remaining[r_type])
				$Panel/ResourceHint.hint_tooltip = res.string_from_id(r_type)
				return

	$Panel/ResourceSprite.hide()
	$Panel/ResourceLabel.hide()

func _on_Dispatcher_selection_cleared():
	su = null
	clear_all()


func _on_Dispatcher_unit_update():
	if not su == null: update_display()


func _on_Dispatcher_resource_selected(resource):
	clear_all()
	su = resource
	update_display()
