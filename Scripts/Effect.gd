extends KinematicBody2D

var direction = Vector2.ZERO
var speed = 0
var effect_type = null
var dir_string = get_tree().root.get_node("Main/GameObjects/Effects").directory_strings

func setup(origin, dir, sp, e_type):
	direction = dir
	speed = sp
	position = origin
	effect_type = e_type
	load_effect()

func load_effect():
	$AnimatedSprite.frames = load(
		"res://Assets/SpriteFrames/Effects/" + dir_string[effect_type] + ".tscn")

func get_speed(): return speed

func _physics_process(delta):
	if direction.length() * speed == 0: return
	var movement = get_speed() * direction * delta
	var _k_collision = move_and_collide(movement)

func on_death():
	queue_free()

func _on_LifeTimer_timeout():
	on_death()
