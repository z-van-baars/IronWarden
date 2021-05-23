extends Control
signal construction_button_pressed

onready var su = null
onready var res
onready var player

func _ready():
	clear_all()

func new_game():
	player = get_tree().root.get_node("Main").local_player
	res = get_tree().root.get_node("Main/GameObjects/Resources")

func _process(_delta):
	update_display()

func clear_all():
	$MainPanel/UnitHeader.hide()
	$HealthBarPanel.hide()
	$ShieldBarPanel.hide()
	$MainPanel/StatBGPanel.hide()
	$MainPanel/ResourceSprite.hide()
	$MainPanel/ResourceSpriteShadow.hide()
	$MainPanel/ResourceLabel.hide()
	$UnitPortrait.hide()
	$MainPanel/ConstructionButton.hide()

func _on_Unit_selected(unit):
	clear_all()
	su = unit
	update_display()

func _unhandled_input(event):
	if event.is_action_pressed("K_b"):
		if not player.constructors_selected(): return
		_on_ConstructionButton_pressed()

func update_display():
	if not su: return

	$MainPanel/SelectedUnitsLabel.text = str(player.get_selected().size())
	$MainPanel/UnitHeader.show()
	$MainPanel/UnitHeader.text = su.get_display_name()

	$UnitPortrait/Thumbnail.texture = su.get_thumbnail()
	$UnitPortrait.show()
	
	if su.has_method("get_maxshields()"):
		$ShieldBarPanel.show()
		$ShieldBarPanel/ShieldBar.max_value = su.get_maxshields()
		$ShieldBarPanel/ShieldBar.value = su.get_shields()

	$HealthBarPanel.show()
	$HealthBarPanel/HealthBar.max_value = su.get_maxhealth()
	$HealthBarPanel/HealthBar.value = su.get_health()
	
	$HealthBarPanel/HealthLabel.show()
	$HealthBarPanel/HealthLabel.text = str(su.get_health()) + " / " + str(su.get_maxhealth())
	$HealthBarPanel/HealthLabelShadow.text = $HealthBarPanel/HealthLabel.text
	
	if su.has_method("get_armor"):
		$MainPanel/StatBGPanel.show()
		$MainPanel/StatBGPanel/ArmorLabel.text = str(su.get_armor())
		$MainPanel/StatBGPanel/AttackLabel.text = str(su.get_attack())
		$MainPanel/StatBGPanel/RangeLabel.text = str(su.get_range())
	else:
		$MainPanel/StatBGPanel.hide()
	$MainPanel/ResourceHint.hint_tooltip = ""
	if su.has_method("can_gather") and su.can_gather():
		for r_type in su.carrying.keys():
			if su.carrying[r_type] > 0:
				$MainPanel/ResourceSprite.show()
				$MainPanel/ResourceSprite.texture = res.icons[r_type]
				$MainPanel/ResourceSpriteShadow.show()
				$MainPanel/ResourceSpriteShadow.texture = res.icons[r_type]
				$MainPanel/ResourceLabel.show()
				$MainPanel/ResourceLabel.text = str(su.get_carried(r_type))
				$MainPanel/ResourceHint.hint_tooltip = res.string_from_id(r_type)
				return
	
	if su.has_method("can_construct") and su.can_construct():
		$MainPanel/ConstructionButton.show()

	if "remaining" in su:
		for r_type in su.remaining.keys():
			if su.remaining[r_type] > 0:
				$MainPanel/ResourceSprite.show()
				$MainPanel/ResourceSprite.texture = res.icons[r_type]
				$MainPanel/ResourceSpriteShadow.show()
				$MainPanel/ResourceSpriteShadow.texture = res.icons[r_type]
				$MainPanel/ResourceLabel.show()
				$MainPanel/ResourceLabel.text = str(su.remaining[r_type])
				$MainPanel/ResourceHint.hint_tooltip = res.string_from_id(r_type)
				return

	$MainPanel/ResourceSprite.hide()
	$MainPanel/ResourceSpriteShadow.hide()
	$MainPanel/ResourceLabel.hide()

func _on_Dispatcher_selection_cleared():
	su = null
	clear_all()


func _on_Dispatcher_unit_update():
	if not su == null: update_display()


func _on_Dispatcher_deposit_selected(deposit):
	clear_all()
	su = deposit
	update_display()


func _on_ConstructionButton_pressed():
	$MainPanel/ConstructionButton.hide()
	emit_signal("construction_button_pressed")

