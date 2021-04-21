extends Node2D

func set_location(location):
	position = location


func play_animation():
	$AnimatedSprite.play("wave")

func stop_animation():
	$AnimatedSprite.stop()

func restart_animation():
	$AnimatedSprite.set_frame(0)


func _on_Dispatcher_rally_point_set(location):
	set_location(location)
	restart_animation()
	play_animation()

func _on_Dispatcher_unit_selected(unit):
	if "rally_point" in unit and unit.rally_point != null:
		set_location(unit.rally_point)
		restart_animation()
		play_animation()
		show()
	if (
		"final_target" in unit
		and unit.final_target != null
		and unit.final_target != unit.position):
		set_location(unit.final_target)
		restart_animation()
		play_animation()
		show()


func _on_Dispatcher_selection_cleared():
	hide()
	stop_animation()


func _on_Dispatcher_set_target_location(target_location):
	set_location(target_location)
	if not $AnimatedSprite.playing:
		$AnimatedSprite.play("wave")
	show()
