extends "res://Scripts/MotileUnit.gd"

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
	

func set_spriteframes(faction_name, _unit_type):
	var name_string = get_display_name().to_lower().replace(" ", "_")
	var anim_path = "res://Assets/SpriteFrames/Units/" + faction_name + "/" + name_string
	$AnimatedSprite.frames = load(anim_path + "/SpriteFrame.tres")
	#$AnimatedSprite.frames = units.spriteframe_ref[_unit_type]
	$AnimatedSprite.offset = Vector2(0, -72)
