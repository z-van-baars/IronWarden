extends "res://Scripts/Unit.gd"

func wander():
	var random_wander_location = tools.radius_random(get_center(), 640, 32)
	move_to(random_wander_location)

func idle_task_logic():
	if $WanderTimer.is_stopped():
		$WanderTimer.start()


func additional_idle_functions():
	$WanderTimer.start(tools.rng.randf_range(3.0, 15.0))

func _on_WanderTimer_timeout():
	wander()
	
