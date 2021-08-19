extends Control
signal construction_button_pressed
signal reform_button_pressed
signal unit_ungrouped

var group_button_scn = preload("res://Scenes/UI/PortraitButton.tscn")
onready var su = []
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
	su = []
	$MainPanel/UnitHeader.hide()
	$MainPanel/SelectedUnitsLabel.hide()
	$MainPanel/SelectedUnitsIcon.hide()
	$MainPanel/Reform.hide()
	$HealthBarPanel.hide()
	$ShieldBarPanel.hide()
	$MainPanel/StatBGPanel.hide()
	$MainPanel/ResourceIcon.hide()
	$MainPanel/ResourceIconShadow.hide()
	$MainPanel/ResourceLabel.hide()
	$UnitPortrait.hide()
	$MainPanel/ConstructionButton.hide()
	$MainPanel/StatusPanel.hide()
	$GroupPanel.hide()


func _unhandled_input(event):
	if event.is_action_pressed("K_b"):
		if not player.constructors_selected(): return
		_on_ConstructionButton_pressed()
	elif event.is_action_pressed("K_q"):
		_on_Reform_pressed()

func update_display():
	if su.empty(): return
	assert(is_instance_valid(su[0]))
	# For some reason this is flagging as true and also giving the Label a string of `1`
	$MainPanel/SelectedUnitsLabel.show()
	$MainPanel/SelectedUnitsIcon.show()
	$MainPanel/SelectedUnitsLabel.text = str(su.size())
	if su.size() > 1:
		$GroupPanel.show()
		build_group_buttons()
		$MainPanel/Reform.show()
	$MainPanel/UnitHeader.show()
	var top_unit = su[0]
	$MainPanel/UnitHeader.text = top_unit.get_display_name()

	$UnitPortrait/Thumbnail.texture = top_unit.get_thumbnail()
	$UnitPortrait.show()

	if top_unit.has_method("get_maxshields"):
		if not top_unit.get_maxshields() == 0 and not top_unit.get_maxshields() == null:
			$ShieldBarPanel.show()
			$ShieldBarPanel/ShieldBar.max_value = top_unit.get_maxshields()
			$ShieldBarPanel/ShieldBar.value = top_unit.get_shields()

	$HealthBarPanel.show()
	$HealthBarPanel/HealthBar.max_value = top_unit.get_maxhealth()
	$HealthBarPanel/HealthBar.value = top_unit.get_health()
	
	$HealthBarPanel/HealthLabel.show()
	$HealthBarPanel/HealthLabel.text = str(top_unit.get_health()) + " / " + str(top_unit.get_maxhealth())
	$HealthBarPanel/HealthLabelShadow.text = $HealthBarPanel/HealthLabel.text
	
	if top_unit.has_method("get_armor") and top_unit.get_armor() != null:
		$MainPanel/StatBGPanel.show()
		$MainPanel/StatBGPanel/ArmorLabel.text = str(top_unit.get_armor())
		$MainPanel/StatBGPanel/AttackLabel.text = str(top_unit.get_attack())
		$MainPanel/StatBGPanel/RangeLabel.text = str(top_unit.get_range())
	else:
		$MainPanel/StatBGPanel.hide()
	$MainPanel/ResourceHint.hint_tooltip = ""
	if top_unit.has_method("can_gather") and top_unit.can_gather():
		for r_type in top_unit.carrying.keys():
			if top_unit.carrying[r_type] > 0:
				$MainPanel/ResourceIcon.show()
				$MainPanel/ResourceIcon.texture = res.icons[r_type]
				$MainPanel/ResourceIconShadow.show()
				$MainPanel/ResourceIconShadow.texture = res.icons[r_type]
				$MainPanel/ResourceLabel.show()
				$MainPanel/ResourceLabel.text = str(top_unit.get_carried(r_type))
				$MainPanel/ResourceHint.hint_tooltip = res.string_from_id(r_type)
				return
	
	if top_unit.has_method("can_construct") and top_unit.can_construct():
		$MainPanel/ConstructionButton.show()

	if "remaining" in top_unit:
		for r_type in top_unit.remaining.keys():
			if top_unit.remaining[r_type] > 0:
				$MainPanel/ResourceIcon.show()
				$MainPanel/ResourceIcon.texture = res.icons[r_type]
				$MainPanel/ResourceIconShadow.show()
				$MainPanel/ResourceIconShadow.texture = res.icons[r_type]
				$MainPanel/ResourceLabel.show()
				$MainPanel/ResourceLabel.text = str(top_unit.remaining[r_type])
				$MainPanel/ResourceHint.hint_tooltip = res.string_from_id(r_type)
				return

	$MainPanel/ResourceIcon.hide()
	$MainPanel/ResourceIconShadow.hide()
	$MainPanel/ResourceLabel.hide()
	
	if not top_unit.has_method("get_state"): return
	$MainPanel/StatusPanel.show()
	$MainPanel/StatusPanel/StateLabel.text = "State - " + str(top_unit.get_state())
	$MainPanel/StatusPanel/TaskLabel.text = "Task - " + str(top_unit.get_task())
	$MainPanel/StatusPanel/TargetLabel.text = "Target - [ "
	if top_unit.get_target() == null:
		$MainPanel/StatusPanel/TargetLabel.text += "None ]"
		return
	$MainPanel/StatusPanel/TargetLabel.text += str(top_unit.get_target_name())
	$MainPanel/StatusPanel/TargetLabel.text += " : " + str(top_unit.get_target_coordinates()) + "]"

func clear_group_buttons():
	for child in $GroupPanel/ButtonGrid.get_children():
		child.queue_free()

func build_group_buttons():
	clear_group_buttons()
	for each in su:
		var new_button = group_button_scn.instance()
		$GroupPanel/ButtonGrid.add_child(new_button)
		new_button.setup(each)
		new_button.connect_signals(self)

func _on_PortraitButton_clicked(unit):
	emit_signal("unit_ungrouped", unit)

func _on_Dispatcher_selection_cleared():
	clear_all()

func _on_Dispatcher_unit_update():
	clear_all()
	su = player.get_selected()
	update_display()


func _on_ConstructionButton_pressed():
	$MainPanel/ConstructionButton.visible = !$MainPanel/ConstructionButton.visible
	emit_signal("construction_button_pressed")


func _on_Reform_pressed():
	emit_signal("reform_button_pressed")





