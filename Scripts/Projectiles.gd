extends YSort
var projectile_scn = preload("res://Scenes/Projectile.tscn")
var beam_scn = preload("res://Scenes/Beam.tscn")
onready var directory_strings = {
	Types.PROJECTILE.LASBOLT: "lasbolt",
	Types.PROJECTILE.LASBEAM: "lasbeam",
	Types.PROJECTILE.BULLET: "bullet",
	Types.PROJECTILE.ARROW: "arrow"
}

onready var projectile_sprites = {
	Types.PROJECTILE.LASBOLT: load(
		"res://Assets/Art/Projectiles/lasbolt.png"),
	Types.PROJECTILE.LASBEAM: load(
		"res://Assets/Art/Projectiles/lasbeam.png"),
	Types.PROJECTILE.BULLET: load(
		"res://Assets/Art/Projectiles/bullet.png"),
	Types.PROJECTILE.ARROW: load(
		"res://Assets/Art/Projectiles/arrow.png")
}

func add_projectile(origin, own_player, target_unit, attack_stats, attacker):
	var new_projectile = projectile_scn.instance()
	add_child(new_projectile)
	new_projectile.setup(
		origin,
		own_player,
		target_unit,
		attack_stats,
		attacker)

func add_beam(origin, own_player, target_unit, attack_stats, attacker):
	var new_beam = beam_scn.instance()
	add_child(new_beam)
	new_beam.setup(
		origin,
		own_player,
		target_unit,
		attack_stats,
		attacker)

func get_projectile_sprite(proj_type):
	return projectile_sprites[proj_type]


