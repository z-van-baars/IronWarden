extends AnimatedSprite


func _on_Player_unit_move_to(location):
	position = location
	# modulate = Color(200, 100, 100)
	set_frame(0)
	show()
	play()


func _on_GroundArrows_animation_finished():
	stop()
	set_frame(0)
	hide()
