extends KinematicBody2D
var direction = Vector2.ZERO
var speed = 0
var particle_type = null
var dir_string = get_tree().root.get_node("Main/GameObjects/Particles").directory_strings

func setup(origin, dir, sp, p_type):
	position = origin
	direction = dir
	speed = sp
	particle_type = p_type
	load_particle_sprite()

func load_particle_sprite():
	var pt_string = dir_string[particle_type]
	$AnimatedSprite.frames = load(
		"res://Assets/Spriteframes/Particles/" + pt_string + "/SpriteFrame.tres")

func get_speed(): return speed

func _physics_process(delta):
	if direction.length() * speed == 0: return
	var movement = get_speed() * direction * delta
	var _k_collision = move_and_collide(movement)

func on_death():
	queue_free()

func _on_LifeTimer_timeout():
	on_death()
