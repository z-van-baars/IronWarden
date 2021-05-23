extends YSort
var particle_scn = preload("res://Scenes/Particle.tscn")

enum ParticleTypes {
	SPARK,
	SMOKE
}
onready var directory_string = {
	
}


func add_particle(origin, dir, p_type):
	var new_particle = particle_scn.instance()
	add_child(new_particle)
	new_particle.setup(origin, dir, p_type)
