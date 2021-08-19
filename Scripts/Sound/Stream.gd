extends Node2D

func _on_new_game():
	# return
	$Timer.stop()
	$SegmentumObscurus.stop()
	# $OuroborousB.play()

func _on_active_menu():
	$Timer.start(
		get_tree().root.get_node("Main/Tools").rng.randf_range(1, 5))


func _on_Timer_timeout():
	# Music Won't play because the scene tree is paused which includes the sound stream node
	$SegmentumObscurus.play()


