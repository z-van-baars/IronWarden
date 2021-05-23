extends "res://Scripts/Projectile.gd"
var beam_length

var fade_time = {
	Types.PROJECTILE.LASBEAM: 1
}

func setup(origin, own_player, target_object, attack_stats, attack_emitter=null):
	proj = get_tree().root.get_node("Main/GameObjects/Projectiles")
	position = origin# + (target_object.position - position) / 2
	direction = (target_object.position - position).normalized()
	beam_length = (target_object.position - position).length()
	
	target_unit = target_object
	player_owner = own_player
	attacker = attack_emitter
	gravity = false
	for stat in attack_stats.keys():
		stats[stat] = attack_stats[stat]
	dir_string = get_tree().root.get_node("Main/GameObjects/Projectiles").directory_strings
	load_projectile_sprite()
	$Sprite.scale.y = beam_length / $Sprite.texture.get_height()
	$Sprite.offset.y = -(beam_length / $Sprite.scale.y) / 2
	set_rotation(target_object.position)
	$LifeTimer.start(attack_stats[AttackStats.LIFESPAN])
	damage(target_unit)


func _physics_process(_delta):
	pass
	
func set_rotation(_target_pos):
	$Sprite.rotation_degrees = rad2deg((direction * 5).angle()) + 90
