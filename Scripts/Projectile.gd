extends KinematicBody2D
onready var effect_scn = preload("res://Scenes/Effect.tscn")
onready var particle_scn = preload("res://Scenes/Particle.tscn")
onready var proj
onready var dir_string
onready var contact_radius = 5
onready var target_unit = null
onready var attacker = null

enum AttackStats {
	PROJ_TYPE,
	SPEED,
	LIFESPAN,
	DAMAGE_TYPE,
	DAMAGE
}

var proj_scales = {
	Types.PROJECTILE.LASBOLT: Vector2(0.2, 0.5),
	Types.PROJECTILE.LASBEAM: Vector2(0.3, 0.1),
	Types.PROJECTILE.PLASMA_BOLT: Vector2(0.1, 0.1),
	Types.PROJECTILE.BULLET: Vector2(0.1, 0.1),
	Types.PROJECTILE.ARROW: Vector2(1, 1)
}
var direction = Vector2.ZERO
var player_owner = null
var gravity = false
var stats = {
	AttackStats.SPEED: 0,
	AttackStats.LIFESPAN: 2,
	AttackStats.DAMAGE_TYPE: null, # Kinetic / Energy
	AttackStats.DAMAGE: 0
	}

func setup(origin, own_player, target_object, attack_stats, attack_emitter=null):
	proj = get_tree().root.get_node("Main/GameObjects/Projectiles")
	position = origin
	direction = (target_object.position - position).normalized()
	target_unit = target_object
	player_owner = own_player
	attacker = attack_emitter
	gravity = false
	for stat in attack_stats.keys():
		stats[stat] = attack_stats[stat]
	dir_string = get_tree().root.get_node("Main/GameObjects/Projectiles").directory_strings
	load_projectile_sprite()
	$Sprite.offset = Vector2(0, $Sprite.texture.get_height())
	set_rotation(target_object.position)
	$LifeTimer.start(attack_stats[AttackStats.LIFESPAN])

func load_projectile_sprite():
	$Sprite.texture = proj.get_projectile_sprite(stats[AttackStats.PROJ_TYPE]).duplicate()
	$Sprite.scale = proj_scales[stats[AttackStats.PROJ_TYPE]]
	
	# $AnimatedSprite.play("fly")

func set_rotation(_target_pos):
	$Sprite.rotation_degrees = rad2deg((direction * 5).angle()) + 90

func get_speed(): return stats[AttackStats.SPEED]
func get_damage_type(): return stats[AttackStats.DAMAGE_TYPE]
func get_damage(): return stats[AttackStats.DAMAGE]

func _physics_process(delta):
	var movement = get_speed() * direction * delta
	var _k_collision = move_and_collide(movement)
	check_impact()

func check_impact():
	var space = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	var contact_zone = CircleShape2D.new()
	contact_zone.radius = contact_radius
	query.set_shape(contact_zone)
	query.transform = Transform2D(0, position)

	var collisions = space.intersect_shape(query)
	for entry in collisions:
		if entry.collider == target_unit:
			damage(entry.collider)
			on_death()
			return true
	return false

func damage(receiver):
	receiver.take_damage(get_damage_type(), get_damage(), attacker)

func on_death():
	queue_free()

func _on_LifeTimer_timeout():
	on_death()
